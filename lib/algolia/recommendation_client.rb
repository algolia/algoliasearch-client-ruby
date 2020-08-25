module Algolia
  module Recommendation
    class Client
      extend Forwardable

      def_delegators :@transporter, :read, :write

      def initialize(recommendation_config, opts = {})
        @config      = recommendation_config
        adapter      = opts[:adapter] || Defaults::ADAPTER
        logger       = opts[:logger] || LoggerHelper.create('debug.log')
        requester    = opts[:http_requester] || Defaults::REQUESTER_CLASS.new(adapter, logger)
        @transporter = Transport::Transport.new(@config, requester)
      end

      # Create a new client providing only app ID and API key
      #
      # @param app_id [String] Algolia application ID
      # @param api_key [String] Algolia API key
      #
      # @return self
      #
      def self.create(app_id, api_key)
        config = Recommendation::Config.new(app_id: app_id, api_key: api_key)
        create_with_config(config)
      end

      def self.create_with_config(config)
        new(config)
      end

      def set_personalization_strategy(personalization_strategy, opts = {})
        write(:POST, '1/strategies/personalization', personalization_strategy, opts)
      end

      def get_personalization_strategy(opts = {})
        read(:GET, '1/strategies/personalization', {}, opts)
      end
    end
  end
end
