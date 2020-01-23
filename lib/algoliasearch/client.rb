require 'faraday'
require 'json'

module Algoliasearch
  # Class Client
  class Client
    # Initialize a client to connect to Algolia
    #
    # @param search_config [SearchConfig] a SearchConfig object which contains your APP_ID and API_KEY
    # @option http_requester [Object] requester object used for the connection
    # @option adapter [Object] adapter object used for the connection
    #
    def initialize(search_config, opts = {})
      if search_config.nil?
        raise ArgumentError, 'Please provide a search config'
      end
      @config         = search_config
      requester_class = opts[:http_requester] || Defaults::REQUESTER_CLASS
      @transporter    = Transport::Transport.new(@config, requester_class, opts)
    end

    # Initialize an index with a given name
    #
    # @param index_name [String] name of the index to init
    #
    # @return [Index] new Index instance
    #
    def init_index(index_name)
      name = index_name.gsub(/\s+/, '')
      if name.nil?
        raise ArgumentError, 'Please provide a valid index name'
      end
      Index.new(name, @transporter, @config)
    end
  end
end
