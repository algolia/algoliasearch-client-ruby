require 'faraday'
require 'json'

require 'algoliasearch/enums/call_type'

module Algoliasearch
  # Class Client
  class SearchConfig < AlgoliaConfig
    include CallType
    attr_accessor :default_hosts, :custom_hosts

    # Initialize a config
    #
    # @option options [String] :app_id
    # @option options [String] :api_key
    # @option options [Integer] :custom_hosts
    #
    def initialize(opts = {})
      super(opts)

      hosts = []
      hosts << Transport::StatefulHost.new("#{app_id}-dsn.algolia.net", accept: READ, up: true, last_use: Time.new)
      hosts << Transport::StatefulHost.new("#{app_id}.algolia.net", accept: WRITE, up: true, last_use: Time.new)

      stateful_hosts = 1.upto(3).map { |i| Transport::StatefulHost.new("#{app_id}-#{i}.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new) }.shuffle

      @default_hosts = hosts + stateful_hosts
      @custom_hosts  = opts[:custom_hosts] || nil
    end
  end
end
