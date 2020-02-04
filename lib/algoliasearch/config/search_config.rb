require 'faraday'
require 'json'

require 'algoliasearch/enums/call_type'

module Algolia
  module Search
    class Config < AlgoliaConfig
      include CallType
      attr_accessor :default_hosts

      # Initialize a config
      #
      # @option options [String] :app_id
      # @option options [String] :api_key
      # @option options [Hash] :custom_hosts
      #
      def initialize(opts = {})
        super(opts)

        hosts = []
        hosts << Transport::StatefulHost.new("#{app_id}-dsn.algolia.net", accept: READ, up: true, last_use: Time.new)
        hosts << Transport::StatefulHost.new("#{app_id}.algolia.net", accept: WRITE, up: true, last_use: Time.new)

        stateful_hosts = 1.upto(3).map do |i|
          Transport::StatefulHost.new("#{app_id}-#{i}.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
        end.shuffle

        @default_hosts = opts[:custom_hosts] || hosts + stateful_hosts
      end
    end
  end
end
