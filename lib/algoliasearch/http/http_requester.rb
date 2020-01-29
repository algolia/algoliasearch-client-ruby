module Algoliasearch
  module Http
    class HttpRequester
      attr_accessor :http_client, :connections

      #
      # @param config [SearchConfig]
      # @option adapter [String] adapter used to make requests. Defaults to Net::Http
      #
      def initialize(config, opts)
        @hosts  = config.custom_hosts || config.default_hosts
        adapter = opts[:adapter] || Faraday.default_adapter

        @connections = {}
        @hosts.each do |host|
          @connections[host.url] = Faraday.new(build_url(host), request: {open_timeout: config.connect_timeout}) do |f|
            f.adapter adapter.to_sym
          end
        end
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
        connection                 = get_connection(host)
        connection.options.timeout = timeout
        response                   = connection.run_request(method, path, body, headers)

        if response.success?
          return Http::Response.new(status: response.status, body: MultiJson.load(response.body), headers: response.headers)
        end

        Http::Response.new(status: response.status, error: MultiJson.load(response.body), headers: response.headers)
        rescue Faraday::TimeoutError => e
          Http::Response.new(error: e.response, timed_out: true)
      end

      # Retrieve the connection from the @connections
      #
      # @param host [StatefulHost]
      #
      # @return [Faraday::Connection]
      #
      def get_connection(host)
        if @connections[host.url].nil?
          raise AlgoliaError, 'Unknown host provided'
        end
        @connections[host.url]
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
