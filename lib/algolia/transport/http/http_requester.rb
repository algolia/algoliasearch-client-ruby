module Algolia
  module Http
    class HttpRequester
      attr_accessor :adapter, :logger

      #
      # @param adapter [Object] adapter used to make requests. Defaults to Net::Http
      # @param logger [Object] logger used to log requests. Defaults to Algolia::LoggerHelper
      #
      def initialize(adapter, logger)
        @adapter = adapter
        @logger = logger
        @connections = {}
      end

      # Sends request to the engine
      #
      # @param host [StatefulHost]
      # @param method [Symbol]
      # @param path [String]
      # @param body [JSON]
      # @param query_params [Hash]
      # @param headers [Hash]
      #
      # @return [Http::Response]
      #
      def send_request(host, method, path, body, query_params, headers, timeout, connect_timeout)
        connection = connection(host)
        connection.options.timeout = timeout / 1000
        connection.options.open_timeout = connect_timeout / 1000
        path += handle_query_params(query_params)

        @logger.info("Sending #{method.to_s.upcase} request to #{path} with body #{body}") if ENV["ALGOLIA_DEBUG"]

        response = connection.run_request(method, path, body, headers)

        if response.success?
          if ENV["ALGOLIA_DEBUG"]
            @logger.info("Request succeeded. Response status: #{response.status}, body: #{response.body}")
          end

          return Http::Response.new(
            status: response.status,
            reason_phrase: response.reason_phrase,
            body: response.body,
            headers: response.headers
          )
        end

        if ENV["ALGOLIA_DEBUG"]
          @logger.info("Request failed. Response status: #{response.status}, error: #{response.body}")
        end

        Http::Response.new(
          status: response.status,
          reason_phrase: response.reason_phrase,
          error: response.body,
          headers: response.headers
        )
      rescue Faraday::TimeoutError => e
        @logger.info("Request timed out. Error: #{e.message}") if ENV["ALGOLIA_DEBUG"]
        Http::Response.new(error: e.message, has_timed_out: true)
      rescue ::StandardError => e
        @logger.info("Request failed. Error: #{e.message}") if ENV["ALGOLIA_DEBUG"]
        Http::Response.new(error: e.message, network_failure: true)
      end

      # Retrieve the connection from the @connections
      #
      # @param host [StatefulHost]
      #
      # @return [Faraday::Connection]
      #
      def connection(host)
        url = build_url(host)
        @connections[url] ||= Faraday.new(url) do |f|
          f.adapter(@adapter.to_sym)
        end
      end

      # Build url from host, path and parameters
      #
      # @param host [StatefulHost]
      #
      # @return [String]
      #
      def build_url(host)
        host.protocol + host.url + (host.port.nil? ? "" : ":#{host.port}")
      end

      # Convert query_params to a full query string
      #
      def handle_query_params(query_params)
        query_params.nil? || query_params.empty? ? "" : "?#{to_query_string(query_params)}"
      end

      # Create a query string from query_params
      #
      def to_query_string(query_params)
        query_params
          .map do |key, value|
            "#{key}=#{value}"
          end
          .join("&")
      end
    end
  end
end
