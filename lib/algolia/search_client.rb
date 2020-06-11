require 'faraday'

module Algolia
  module Search
    # Class Client
    class Client
      # Initialize a client to connect to Algolia
      #
      # @param search_config [Search::Config] a Search::Config object which contains your APP_ID and API_KEY
      # @option http_requester [Object] requester object used for the connection
      # @option adapter [Object] adapter object used for the connection
      #
      def initialize(search_config, opts = {})
        @config         = search_config
        requester_class = opts[:http_requester] || Defaults::REQUESTER_CLASS
        logger_class    = opts[:logger]
        @transporter    = Transport::Transport.new(@config, logger_class, requester_class, opts)
      end

      def self.create(app_id, api_key)
        config = Search::Config.new(app_id: app_id, api_key: api_key)
        new(config)
      end

      # Initialize an index with a given name
      #
      # @param index_name [String] name of the index to init
      #
      # @return [Index] new Index instance
      #
      def init_index(index_name)
        index_name.strip!
        if index_name.empty?
          raise ArgumentError, 'Please provide a valid index name'
        end
        Index.new(index_name, @transporter, @config)
      end

      def list_indexes(opts = {})
        @transporter.read(:GET, "#{Defaults::VERSION}/indexes", opts)
      end

      def multiple_batch(operations, opts = {})
        @transporter.write(:POST, "#{Defaults::VERSION}/indexes/*/batch", {requests: operations}, opts)
      end
    end
  end
end
