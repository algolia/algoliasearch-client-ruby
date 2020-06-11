module Algolia
  module Http
    class HttpRequester
      attr_accessor :http_client, :logger, :connections

      #
      # @param config [Search::Config]
      # @option adapter [String] adapter used to make requests. Defaults to Net::Http
      #
      def initialize(config, logger = nil, opts = {})
        @config     = config
        @hosts      = @config.default_hosts
        @adapter    = opts[:adapter] || Defaults::ADAPTER
        logger    ||= LoggerHelper
        @logger     = logger.create 'debug.log'
        @connection = nil
      end

      # Sends request to the engine
      #
      # @param host [StatefulHost]
      # @param method [Symbol]
      # @param path [String]
      # @param body [JSON]
      # @param headers [Hash]
      #
      # @return [Http::Response]
      #
      def send_request(host, method, path, body, headers, timeout)
        connection                 = connection(host)
        connection.options.timeout = timeout

        if ENV['ALGOLIA_DEBUG']
          @logger.info("Sending #{method.to_s.upcase!} request to #{path} with body #{body}")
        end

        response = connection.run_request(method, path, body, headers)

        if response.success?
          if ENV['ALGOLIA_DEBUG']
            @logger.info("Request succeeded. Response status: #{response.status}, body: #{response.body}")
          end
          return Http::Response.new(status: response.status, body: Helpers.json_to_hash(response.body), headers: response.headers)
        end

        if ENV['ALGOLIA_DEBUG']
          @logger.info("Request failed. Response status: #{response.status}, error: #{response.body}")
        end
        response_body = Helpers.json_to_hash(response.body)
        Http::Response.new(status: response.status, error: response_body['message'], headers: response.headers)
      rescue Faraday::TimeoutError => e
        if ENV['ALGOLIA_DEBUG']
          @logger.info("Request timed out. Error: #{e.message}")
        end
        Http::Response.new(error: e.message, has_timed_out: true)
      rescue ::StandardError => e
        if ENV['ALGOLIA_DEBUG']
          @logger.info("Request failed. Error: #{e.message}")
        end
        Http::Response.new(error: e.message)
      end

      # Retrieve the connection from the @connections
      #
      # @param host [StatefulHost]
      #
      # @return [Faraday::Connection]
      #
      def connection(host)
        @connection ||= Faraday.new(build_url(host), request: {open_timeout: @config.connect_timeout}) do |f|
          f.adapter @adapter.to_sym
        end
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
