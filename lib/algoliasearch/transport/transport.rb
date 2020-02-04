require 'faraday'

module Algolia
  module Transport
    class Transport
      include RetryOutcomeType
      include CallType

      #
      # @param config [Search::Config] config used for search
      # @param logger_class [Object] logger used for debug
      # @param requester_class [Object] requester used for sending requests. Uses Algolia::Http::HttpRequester by default
      # @option adapter [String] adapter used for sending requests, if needed. Uses Faraday.default_adapter by default
      #
      def initialize(config, logger_class = nil, requester_class = nil, opts = {})
        @config           = config
        requester_class ||= Defaults::REQUESTER_CLASS
        @http_requester   = requester_class.new(config, logger_class, opts)
        @retry_strategy   = RetryStrategy.new(config)
      end

      # Build a request with call type READ
      #
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      def read(method, path, body: {}, opts: {})
        request(READ, method, path, body, opts)
      end

      # Build a request with call type WRITE
      #
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      def write(method, path, body: {}, opts: {})
        request(WRITE, method, path, body, opts)
      end

      #
      # @param call_type [Binary] READ or WRITE operation
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      # @return [Response] response of the request
      #
      def request(call_type, method, path, body = {}, opts = {})
        @retry_strategy.get_tryable_hosts(call_type).each do |host|
          opts[:timeout] ||= get_timeout(call_type) * (host.retry_count + 1)

          request_options = Http::RequestOptions.new(@config)
          request_options.create(opts)

          request = build_request(method, path, body, request_options)

          response = @http_requester.send_request(
            host,
            request[:method],
            request[:path],
            request[:body],
            request[:headers],
            request[:timeout]
          )

          outcome  = @retry_strategy.decide(host, response.status, response.has_timed_out)
          if outcome == FAILURE
            raise AlgoliaApiError.new(response.status, response.error['message'])
          end
          return response.body unless outcome == RETRY
        end
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
        request           = {}
        request[:method]  = method.downcase
        request[:path]    = build_uri_path(path, request_options.params)
        request[:body]    = build_body(body)
        request[:headers] = generate_headers(request_options)
        request
      end

      # Build the uri from path and additional params
      #
      # @param [Object] path
      # @param [Object] params
      #
      # @return [String]
      #
      def build_uri_path(path, params)
        path + Helpers.handle_params(params)
      end

      # Build the body of the request
      #
      # @param [Hash] body
      #
      # @return [Hash]
      #
      def build_body(body)
        Helpers.to_json(body)
      end

      # Generates headers from config headers and optional parameters
      #
      # @option options [String] :headers
      #
      # @return [Hash] merged headers
      #
      def generate_headers(request_options = {})
        headers                                                     = {}
        extra_headers                                               = request_options.headers || {}
        @config.default_headers.each { |key, val| headers[key.to_s] = val }
        extra_headers.each { |key, val| headers[key.to_s]           = val }
        if request_options.compression_type == Defaults::GZIP_ENCODING
          headers['Accept-Encoding']  = Defaults::GZIP_ENCODING
        end
        headers
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
