require 'faraday'

module Algoliasearch
  module Transport
    class Transport
      include RetryOutcomeType

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
      # @param call_kind [Binary] READ or WRITE operation
      # @param method [Symbol] method used for request
      # @param path [String] path of the request
      # @param params [Hash] request parameters
      # @param body [Hash] request body
      # @param opts [Hash] optional request parameters
      #
      # @return [Response] response of the request
      #
      def request(call_kind, method, path, params = {}, body = {}, opts = {})
        @retry_strategy.get_tryable_hosts(call_kind).each do |host|
          requester = @http_requester.new
          headers = generate_headers(opts)
          opts.delete(:headers)
          url = build_url(host, path, params)
          response = requester.send_request(
            method.downcase,
            url,
            convert_to_json(body),
            headers,
            opts
          )
          outcome = @retry_strategy.decide(host, response[:status])

          return Response.new(response[:status], JSON.parse(response[:body]), response[:headers]) unless outcome == RETRY
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
        @config.headers.each { |key, val| headers[key.to_s] = val }
        extra_headers.each { |key, val| headers[key.to_s] = val }
        headers
      end

      # Build url from host, path and parameters
      #
      # @param host [StatefulHost]
      # @param path [String]
      # @param params [Hash]
      #
      # @return [String]
      #
      def build_url(host, path, params)
        host.protocol + host.url + path + (params.empty? ? '' : "?#{::Faraday::Utils::ParamsHash[params].to_query}")
      end

      def convert_to_json(body)
        body.is_a?(String) ? body : MultiJson.dump(body)
      end
    end
  end
end
