require "faraday"

# this is the default adapter and it needs to be required to be registered.
require "faraday/net_http_persistent" unless Faraday::VERSION < "1"
require "zlib"

module Algolia
  module Transport
    def self.encode_uri(uri)
      CGI.escape(uri).gsub("+", "%20")
    end

    def self.stringify_query_params(query_params)
      query_params.to_h do |key, value|
        value = value.join(",") if value.is_a?(Array)
        [encode_uri(key.to_s).to_sym, encode_uri(value.to_s)]
      end
    end

    class Transport
      include RetryOutcomeType
      include CallType

      # @param config [Configuration]
      # @param requester [Object] requester used for sending requests. Uses Algolia::Http::HttpRequester by default
      # @param request_id_support [true, false] the generated per-client Request-ID capability
      #
      def initialize(config, requester, request_id_support: false)
        @config = config
        @requester = requester
        @request_id_support = request_id_support
        @retry_strategy = RetryStrategy.new(config.hosts)
      end

      # Whether the transport mints Request-ID headers. Resolved per request so a
      # caller can flip config.request_id_enabled at any time, like every other
      # Configuration setting; nil falls back to the per-client capability.
      #
      # @return [true, false]
      #
      def request_id_enabled?
        @config.request_id_enabled.nil? ? @request_id_support : @config.request_id_enabled
      end

      # @param call_type [Binary] READ or WRITE operation
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] contains extra parameters to send with your query
      #
      # @return [Response] response of the request
      #
      def request(call_type, method, path, body, opts = {})
        retry_errors = []

        # The Request-ID is minted once per execution, before the host loop, so that
        # every retry attempt shares the same value and each subsequent call gets a
        # fresh one.
        request_id = mint_request_id(opts)

        # create consumes these two channels from opts on every attempt: snapshot them
        # so retries keep them. Timeout keys stay consumable, recomputed per host below.
        header_params = opts[:header_params]
        query_params = opts[:query_params]

        # The Correlation-ID of the last retried attempt whose response carried a
        # non-empty one, surfaced on the exhaustion error for support tickets.
        last_correlation_id = nil

        @retry_strategy.get_tryable_hosts(call_type).each do |host|
          opts[:header_params] ||= header_params
          opts[:query_params] ||= query_params
          opts[:timeout] ||= get_timeout(call_type)
          opts[:connect_timeout] ||= (@config.connect_timeout || Defaults::CONNECT_TIMEOUT) * (host.retry_count + 1)

          request_options = RequestOptions.new(@config)
          request_options.create(opts)
          # TODO: what is this merge for ?
          # request_options.query_params.merge!(request_options.data) if method == :GET

          request = build_request(method, path, body, request_options, request_id)
          response = @requester.send_request(
            host,
            request[:method],
            request[:path],
            request[:body],
            request[:query_params],
            request[:header_params],
            request[:timeout],
            request[:connect_timeout]
          )

          outcome = @retry_strategy.decide(
            host,
            http_response_code: response.status,
            is_timed_out: response.has_timed_out,
            network_failure: response.network_failure
          )
          if outcome == FAILURE
            correlation_id = correlation_id_from(response.headers)

            # handle HTML error
            if response.headers["content-type"]&.include?("text/html")
              raise Algolia::AlgoliaHttpError.new(response.status, response.reason_phrase, correlation_id)
            end

            decoded_error = JSON.parse(response.error, :symbolize_names => true)
            raise Algolia::AlgoliaHttpError.new(response.status, decoded_error[:message], correlation_id)
          end

          if outcome == RETRY
            correlation_id = correlation_id_from(response.headers)
            last_correlation_id = correlation_id unless correlation_id.nil? || correlation_id.empty?
            retry_errors << {host: host.url, error: response.error}
          else
            return response
          end
        end

        raise(
          Algolia::AlgoliaUnreachableHostError.new(
            "Unreachable hosts. If the error persists, please visit our help center https://alg.li/support-unreachable-hosts or reach out to the Algolia Support team: https://alg.li/support",
            retry_errors,
            last_correlation_id
          )
        )
      end

      private

      # Returns a fresh Request-ID, or nil when the feature is off for this client
      # or the caller already supplied one through the request options, the config
      # default headers, or the x-algolia-request-id query parameter. Caller-supplied
      # values ride their own channel on every attempt.
      #
      # @param opts [Hash]
      #
      # @return [String, nil]
      #
      def mint_request_id(opts)
        return nil unless request_id_enabled?
        return nil if RequestId.request_id?(opts[:header_params])
        return nil if RequestId.request_id?(@config.header_params)
        return nil if RequestId.request_id_query_param?(opts[:query_params])

        RequestId.generate
      end

      # Reads the Correlation-ID header of a failed response case-insensitively: the
      # headers hash keeps the server's casing and defaults to an empty string on
      # timeout and network failures. The unrelated X-Algolia-RequestID edge header
      # must never be read instead.
      #
      # @param headers [Hash, String]
      #
      # @return [String, nil]
      #
      def correlation_id_from(headers)
        return nil unless headers.respond_to?(:each_pair)

        headers.find { |k, _| k.to_s.casecmp?(RequestId::CORRELATION_HEADER) }&.last
      end

      # Parse the different information and build the request
      #
      # @param [Symbol] method
      # @param [String] path
      # @param [Hash] body
      # @param [RequestOptions] request_options
      # @param [String, nil] request_id
      #
      # @return [Hash]
      #
      def build_request(method, path, body, request_options, request_id = nil)
        request = {}
        request[:method] = method.downcase
        request[:path] = path
        request[:body] = build_body(body, request_options)
        request[:query_params] = Algolia::Transport.stringify_query_params(request_options.query_params)

        request[:header_params] = generate_header_params(body, request_options, request_id)
        request[:timeout] = request_options.timeout
        request[:connect_timeout] = request_options.connect_timeout
        request
      end

      # Builds the body of the request, with gzip compression if needed
      def build_body(body, request_options)
        return nil if body.nil?

        if request_options.compression_type == "gzip"
          body = Zlib.gzip(body)
        end

        body
      end

      # Generates headers from config headers and optional parameters
      #
      # @param body [String, nil]
      # @param request_options [RequestOptions]
      # @param request_id [String, nil]
      #
      # @return [Hash] merged headers
      #
      def generate_header_params(body, request_options, request_id = nil)
        header_params = request_options.header_params.transform_keys(&:downcase)
        header_params = @config.header_params.merge(header_params)
        header_params[RequestId::HEADER] = request_id if request_id
        if request_options.compression_type == "gzip" && body.is_a?(String) && !body.to_s.strip.empty?
          header_params["content-encoding"] = "gzip"
        end

        header_params
      end

      # Retrieves a timeout according to call_type
      #
      # @param call_type [Binary] requested call type
      #
      # @return [Integer]
      #
      def get_timeout(call_type)
        case call_type
        when READ
          @config.read_timeout || Defaults::READ_TIMEOUT
        else
          @config.write_timeout || Defaults::WRITE_TIMEOUT
        end
      end
    end
  end
end
