require 'faraday'
require 'json'

require 'algolia/enums/call_type'

module Algolia
  module Analytics
    class Config < AlgoliaConfig
      include CallType
      attr_accessor :region, :default_hosts

      # Initialize a config
      #
      # @option options [String] :app_id
      # @option options [String] :api_key
      # @option options [Hash] :custom_hosts
      #
      def initialize(opts = {})
        super(opts)

        @region        = opts[:region] || 'us'
        @default_hosts = [Transport::StatefulHost.new("analytics.#{region}.algolia.com")]
      end
    end
  end
end
