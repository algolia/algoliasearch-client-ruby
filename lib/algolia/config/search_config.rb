require 'faraday'
require 'json'

require 'algolia/enums/call_type'

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
        @default_hosts = []
        hosts          = []
        hosts << Transport::StatefulHost.new("#{app_id}-dsn.algolia.net", accept: READ, up: true, last_use: Time.new)
        hosts << Transport::StatefulHost.new("#{app_id}.algolia.net", accept: WRITE, up: true, last_use: Time.new)

        stateful_hosts = 1.upto(3).map do |i|
          Transport::StatefulHost.new("#{app_id}-#{i}.algolianet.com", accept: READ | WRITE, up: true, last_use: Time.new)
        end.shuffle

        if opts.has_key?(:custom_hosts)
          opts[:custom_hosts].each do |host|
            host = Transport::StatefulHost.new(host)
            @default_hosts.push(host)
          end
        else
          @default_hosts = hosts + stateful_hosts
        end
      end
    end
  end
end
