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
      #
      def initialize(config, requester)
        @config = config
        @requester = requester
        @retry_strategy = RetryStrategy.new(config.hosts)
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

        @retry_strategy.get_tryable_hosts(call_type).each do |host|
          opts[:timeout] ||= get_timeout(call_type) * (host.retry_count + 1)
          opts[:connect_timeout] ||= @config.connect_timeout * (host.retry_count + 1)

          request_options = RequestOptions.new(@config)
          request_options.create(opts)
          # TODO: what is this merge for ?
          # request_options.query_params.merge!(request_options.data) if method == :GET

          request = build_request(method, path, body, request_options)
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
            # handle HTML error
            if response.headers["content-type"]&.include?("text/html")
              raise Algolia::AlgoliaHttpError.new(response.status, response.reason_phrase)
            end

            decoded_error = JSON.parse(response.error, :symbolize_names => true)
            raise Algolia::AlgoliaHttpError.new(response.status, decoded_error[:message])
          end

          if outcome == RETRY
            retry_errors << {host: host.url, error: response.error}
          else
            return response
          end
        end

        raise Algolia::AlgoliaUnreachableHostError.new("Unreachable hosts.", retry_errors)
      end

      private

      # Parse the different information and build the request
      #
      # @param [Symbol] method
      # @param [String] path
      # @param [Hash] body
      # @param [RequestOptions] request_options
      #
      # @return [Hash]
      #
      def build_request(method, path, body, request_options)
        request = {}
        request[:method] = method.downcase
        request[:path] = path
        request[:body] = build_body(body, request_options)
        request[:query_params] = Algolia::Transport.stringify_query_params(request_options.query_params)
        request[:header_params] = generate_header_params(body, request_options)
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
      # @param request_options [RequestOptions]
      #
      # @return [Hash] merged headers
      #
      def generate_header_params(body, request_options)
        header_params = request_options.header_params.transform_keys(&:downcase)
        header_params = @config.header_params.merge(header_params)
        header_params["accept-encoding"] = "gzip" if request_options.compression_type == "gzip"
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
          @config.read_timeout
        else
          @config.write_timeout
        end
      end
    end
  end
end
