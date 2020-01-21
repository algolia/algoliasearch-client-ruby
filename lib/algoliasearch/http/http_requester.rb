module Algoliasearch
  module Http
    class HttpRequester
      attr_accessor :http_client, :connections

      # type object not perfect
      #
      #
      # @param http_client [Object] client used to make requests. Defaults to Faraday
      #
      def initialize(http_client = nil)
        @http_client = http_client || Faraday
        @connections = {}
      end

      # Sends request to the engine
      #
      # @param host [StatefulHost]
      # @param method [Symbol]
      # @param path [String]
      # @param body [JSON]
      # @param headers [Hash]
      #
      # @return [Transport::Response]
      #
      def send_request(host, method, path, body, headers)
        connection = get_connection(host)
        response = connection.run_request(method, path, body, headers)

        if response.success?
          return Transport::Response.new(status: response.status, body: MultiJson.load(response.body), headers: response.headers)
        end

        Transport::Response.new(status: response.status, error: MultiJson.load(response.body), headers: response.headers)
        rescue Faraday::TimeoutError => e
          Transport::Response.new(error: e.response, timed_out: true)
      end

      def get_connection(host)
        build_connection(host) unless @connections.has_key?(host.url)
      end

      # Build the actual connection
      #
      # @param host [String]
      #
      # @return [Faraday::Connection] new connection
      #
      def build_connection(host)
        @connections[host.url] = Faraday.new(build_url(host))
      end

      # Build url from host, path and parameters
      #
      # @param host [StatefulHost]
      #
      # @return [String]
      #
      def build_url(host)
        host.protocol + host.url
      end
    end
  end
end
