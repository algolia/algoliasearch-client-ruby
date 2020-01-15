module Algoliasearch
  module Http
    class HttpRequester
      #
      # @param http_client [Object] client used to make requests. Defaults to Faraday
      #
      def initialize(http_client = nil)
        @http_client = Faraday
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
      def send_request(method, url, body, headers, opts)
        connection = build_connection(url, headers)
        connection.run_request(method, url, body, opts).to_hash
      end

      # Build the actual connection
      #
      # @param headers [Hash]
      #
      # @return [Faraday::Connection] new connection
      #
      def build_connection(url, headers)
        Faraday.new(url: url, params: {}, headers: headers)
      end
    end
  end
end
