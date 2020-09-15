module Algolia
  module Recommendation
    class Client
      # Initializes the Recommendation client
      #
      # @param recommendation_config [Recommendation::Config] a Recommendation::Config object which contains your APP_ID and API_KEY
      # @option adapter [Object] adapter object used for the connection
      # @option logger [Object]
      # @option http_requester [Object] http_requester object used for the connection
      #
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

      # Create a new client providing only an Recommendation::Config object
      #
      # @param config [Recommendation::Config]
      #
      # @return self
      #
      def self.create_with_config(config)
        new(config)
      end

      # Set the personalization strategy.
      #
      # @param personalization_strategy [Hash] A strategy object.
      #
      # @return [Hash]
      #
      def set_personalization_strategy(personalization_strategy, opts = {})
        @transporter.write(:POST, '1/strategies/personalization', personalization_strategy, opts)
      end

      # Get the personalization strategy.
      #
      # @return [Hash]
      #
      def get_personalization_strategy(opts = {})
        @transporter.read(:GET, '1/strategies/personalization', {}, opts)
      end
    end
  end
end
