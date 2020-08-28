module Algolia
  module Insights
    class Config < AlgoliaConfig
      attr_accessor :region, :default_hosts

      # Initialize a config
      #
      # @option options [String] :app_id
      # @option options [String] :api_key
      # @option options [String] :region
      #
      def initialize(opts = {})
        super(opts)

        @region        = opts[:region] || 'us'
        @default_hosts = [Transport::StatefulHost.new("insights.#{region}.algolia.io")]
      end
    end
  end
end
