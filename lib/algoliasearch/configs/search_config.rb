require 'faraday'
require 'json'

module Algoliasearch
  # Class Client
  class SearchConfig < AlgoliaConfig
    include CallType
    attr_accessor :app_id, :api_key, :default_hosts, :custom_hosts

    # Initialize a config
    #
    # @param app_id [String] Application ID
    # @param api_key [String] API key
    #
    def initialize(app_id, api_key)
      @app_id = app_id
      @api_key = api_key

      hosts = []
      hosts << StatefulHost.new("#{app_id}-dsn.algolia.net", accept: READ, up: true, last_use: Time.new)
      hosts << StatefulHost.new("#{app_id}.algolia.net", accept: WRITE, up: true, last_use: Time.new)

      stateful_hosts = []
      stateful_hosts << StatefulHost.new("#{app_id}-1.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts << StatefulHost.new("#{app_id}-2.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts << StatefulHost.new("#{app_id}-3.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts.shuffle!

      @default_hosts = hosts + stateful_hosts
    end
  end
end
