require 'faraday'

module Algoliasearch
  module Transport
    class Transport
      include RetryOutcomeType
      include CallType

      DEFAULT_TRANSPORT_CLASS = Algoliasearch::Http::HttpRequester

      #
      # @param config [SearchConfig] config used for search
      # @param http_requester [Object] requester used for sending requests. Uses Algoliasearch::Http::HttpRequester by default
      #
      def initialize(config, http_requester = nil)
        if config.nil?
          raise ArgumentError, 'Please provide a search config'
        end

        @config = config
        @http_requester = http_requester || DEFAULT_TRANSPORT_CLASS
        @retry_strategy = RetryStrategy.new(config)
      end

      #
      # @param call_type [Binary] READ or WRITE operation
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param params [Hash] request parameters
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      # @return [Response] response of the request
      #
      def request(call_type, method, path, params = {}, body = {}, opts = {})
        @retry_strategy.get_tryable_hosts(call_type).each do |host|
          requester = @http_requester.new
          opts[:timeout] ||= get_timeout(call_type).to_f * (host.retry_count + 1).to_f
          headers = generate_headers(opts)
          opts.delete(:headers)
          url = build_url(host, path)

          response = requester.send_request(
            method.downcase,
            url,
            params,
            Helpers.convert_to_json(body),
            headers,
            opts
          )
          outcome = @retry_strategy.decide(host, response.status, response.timed_out)

          return response unless outcome == RETRY
        end
      end

      private

      # Generates headers from config headers and optional parameters
      #
      # @option options [String] :headers
      #
      # @return [Array] merged headers
      #
      def generate_headers(opts = {})
        headers = {}
        extra_headers = opts[:headers] || opts['headers'] || {}
        @config.default_headers.each { |key, val| headers[key.to_s] = val }
        extra_headers.each { |key, val| headers[key.to_s] = val }
        headers
      end

      # Build url from host, path and parameters
      #
      # @param host [StatefulHost]
      # @param path [String]
      #
      # @return [String]
      #
      def build_url(host, path)
        host.protocol + host.url + path
      end

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
