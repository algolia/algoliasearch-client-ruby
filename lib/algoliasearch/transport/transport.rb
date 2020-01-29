require 'faraday'

module Algoliasearch
  module Transport
    class Transport
      include RetryOutcomeType
      include CallType

      #
      # @param config [SearchConfig] config used for search
      # @param http_requester [String] requester used for sending requests. Uses Algoliasearch::Http::HttpRequester by default
      # @option adapter [String] adapter used for sending requests, if needed. Uses Faraday.default_adapter by default
      #
      def initialize(config, http_requester = nil, opts = {})
        if config.nil?
          raise ArgumentError, 'Please provide a search config'
        end

        @config         = config
        requester_class = http_requester || Defaults::REQUESTER_CLASS
        @http_requester = requester_class.new(config, opts)
        @retry_strategy = RetryStrategy.new(config)
      end

      # Build a request with call type READ
      #
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      def read(method, path, body = {}, opts = {})
        request(READ, method, path, body, opts)
      end

      # Build a request with call type WRITE
      #
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      def write(method, path, body = {}, opts = {})
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
          timeout         = opts[:request_timeout] || get_timeout(call_type).to_f * (host.retry_count + 1).to_f
          request_options = Http::RequestOptions.new(@config)

          request_options.create(opts)
          request = build_request(method, path, body, request_options)

          response = @http_requester.send_request(
            host,
            request[:method],
            request[:path],
            request[:body],
            request[:headers],
            timeout
          )

          outcome  = @retry_strategy.decide(host, response.status, response.timed_out)

          if outcome == FAILURE
            raise AlgoliaApiError.new(response.status, response.error)
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
      # @param [Hash] request_options
      #
      # @return [Hash]
      #
      def build_request(method, path, body, request_options)
        request           = {}
        request[:method]  = method.downcase
        request[:path]    = build_uri_path(path, request_options.params)
        request[:body]    = build_body(body)
        request[:headers] = generate_headers(request_options.headers)
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
      # @return [String]
      #
      def build_body(body)
        Helpers.to_json(body)
      end

      # Generates headers from config headers and optional parameters
      #
      # @option options [String] :headers
      #
      # @return [Array] merged headers
      #
      def generate_headers(opts = {})
        headers                                                     = {}
        extra_headers                                               = opts[:headers] || opts['headers'] || {}
        @config.default_headers.each { |key, val| headers[key.to_s] = val }
        extra_headers.each { |key, val| headers[key.to_s]           = val }
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
        when WRITE
          @config.write_timeout
        else
          @config.write_timeout
        end
      end
    end
  end
end
