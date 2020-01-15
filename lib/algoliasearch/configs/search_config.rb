require 'faraday'
require 'json'

require 'algoliasearch/enums/call_type'

module Algoliasearch
  DEFAULT_USER_AGENT = ["Algolia for Ruby (#{::Algoliasearch::VERSION})", "Ruby (#{RUBY_VERSION})"]

  # Class Client
  class SearchConfig < AlgoliaConfig
    include CallType
    attr_accessor :app_id, :api_key, :headers, :default_hosts, :custom_hosts

    # Initialize a config
    #
    # @param app_id [String] Application ID
    # @param api_key [String] API key
    #
    def initialize(app_id, api_key, opts = {})
      @app_id = app_id
      @api_key = api_key

      hosts = []
      hosts << Transport::StatefulHost.new("#{app_id}-dsn.algolia.net", accept: READ, up: true, last_use: Time.new)
      hosts << Transport::StatefulHost.new("#{app_id}.algolia.net", accept: WRITE, up: true, last_use: Time.new)

      stateful_hosts = []
      stateful_hosts << Transport::StatefulHost.new("#{app_id}-1.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts << Transport::StatefulHost.new("#{app_id}-2.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts << Transport::StatefulHost.new("#{app_id}-3.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
      stateful_hosts.shuffle!

      @default_hosts = hosts + stateful_hosts

      @headers = {
        Http::Protocol::HEADER_API_KEY => @api_key,
        Http::Protocol::HEADER_APP_ID  => @app_id,
        'Content-Type'           => 'application/json; charset=utf-8',
        'User-Agent'             => DEFAULT_USER_AGENT.push(opts[:user_agent]).uniq.compact.join('; ')
      }
    end
  end
end
