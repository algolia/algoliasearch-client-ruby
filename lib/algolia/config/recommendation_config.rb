module Algolia
  module Recommendation
    class Config < AlgoliaConfig
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
        @default_hosts = [Transport::StatefulHost.new("recommendation.#{region}.algolia.com")]
      end
    end
  end
end
