module Algoliasearch
  module Http
    class HttpRequester
      #
      # @param http_client [Object] client used to make requests. Defaults to Faraday
      #
      def initialize(http_client = nil)
        @http_client = http_client || Faraday
      end

      # Sends request to the engine
      #
      # @param method [Symbol]
      # @param url [String]
      # @param body [JSON]
      # @param headers [Hash]
      # @param opts [Hash]
      #
      # @return [Faraday::Response]
      #
      def send_request(method, url, params, body, headers, opts)
        connection = build_connection(url, params, opts)
        response = connection.run_request(method, url, body, headers)

        return Transport::Response.new(status: response.status, body: MultiJson.load(response.body), headers: response.headers) if response.success?
        Transport::Response.new(status: response.status, error: MultiJson.load(response.body), headers: response.headers)
        rescue Faraday::TimeoutError => e
          Transport::Response.new(error: e.response, timed_out: true)
      end

      # Build the actual connection
      #
      # @param url [String]
      # @param params [Hash]
      # @param opts [Hash]
      #
      # @return [Faraday::Connection] new connection
      #
      def build_connection(url, params, opts)
        Faraday.new(url: url, params: params, request: opts)
      end
    end
  end
end
