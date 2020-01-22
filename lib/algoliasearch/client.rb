require 'faraday'
require 'json'

module Algoliasearch
  # Class Client
  class Client
    # Initialize a client to connect to Algolia
    #
    # @param search_config [SearchConfig] a SearchConfig object which contains your APP_ID and API_KEY
    # @param http_requester [Object] requester object used for the connection
    #
    def initialize(search_config, http_requester = nil)
      if search_config.nil?
        raise ArgumentError, 'Please provide a search config'
      end
      @config = search_config
      @transporter = Transport::Transport.new(@config, http_requester)
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
