require 'faraday'
require 'json'

module Algoliasearch
  # Class Client
  class Client
    # Initialize a client to connect to Algolia
    #
    # @param transporter [Object] transport object used for the connection
    # @param search_config [Config] a Config object which contains your APP_ID and API_KEY
    #
    def initialize(transporter, search_config)
      @transporter = transporter
      @config = search_config
    end

    # Creates the client from options
    #
    # @option options [String] :app_id Application ID
    # @option options [String] :api_key API key
    # @option options [String] :adapter adapter you want to use for the connection
    #
    # @return [Client] new Client instance
    #
    def self.create(options = {})
      if options[:app_id].nil?
        raise ArgumentError, 'No APPLICATION_ID provided, please set :app_id'
      end
      if options[:api_key].nil?
        raise ArgumentError, 'No API_KEY provided, please set :api_key'
      end

      app_id = options[:app_id]
      api_key = options[:api_key]
      transporter = Faraday.new "https://#{app_id}-dsn.algolia.net/" do |con|
        con.adapter options[:adapter] || Faraday.default_adapter
      end
      config = SearchConfig.new(app_id, api_key)
      SearchConfig.new(transporter, config)
    end

    # Initialize an index with a given name
    #
    # @param index_name [String] name of the index to init
    #
    # @return [Index] new Index instance
    #
    def init_index(index_name)
      Index.new(index_name, @transporter, @config)
    end
  end
end
