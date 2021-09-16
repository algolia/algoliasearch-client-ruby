module Algolia
  module Recommend
    class Client
      include Helpers

      BOUGHT_TOGETHER  = 'bought-together'
      RELATED_PRODUCTS = 'related-products'

      # Initializes the Recommend client
      #
      # @param recommend_config [Recommend::Config] a Recommend::Config object which contains your APP_ID and API_KEY
      # @option adapter [Object] adapter object used for the connection
      # @option logger [Object]
      # @option http_requester [Object] http_requester object used for the connection
      #
      def initialize(recommend_config, opts = {})
        @config      = recommend_config
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
        config = Recommend::Config.new(application_id: app_id, api_key: api_key)
        create_with_config(config)
      end

      # Create a new client providing only an Recommend::Config object
      #
      # @param config [Recommend::Config]
      #
      # @return self
      #
      def self.create_with_config(config)
        new(config)
      end

      # Get recommendation for the given queries
      #
      # @param queries [Array<Hash>] the queries to retrieve recommendations for
      # @param opts [Hash] extra parameters to send with your request
      #
      # @return [Hash]
      #
      def get_recommendations(queries, opts = {})
        @transporter.write(
          :POST,
          '/1/indexes/*/recommendations',
          { requests: format_recommendation_queries(queries.map { |q| symbolize_hash(q) }) },
          opts
        )
      end

      # Get related products for the given queries
      #
      # @param queries [Array<Hash>] the queries to get related products for
      # @param opts [Hash] extra parameters to send with your request
      #
      # @return [Hash]
      #
      def get_related_products(queries, opts = {})
        get_recommendations(
          set_query_models(queries.map { |q| symbolize_hash(q) }, RELATED_PRODUCTS),
          opts
        )
      end

      # Get frequently bought together items for the given queries
      #
      # @param queries [Array<Hash>] the queries to get frequently bought together items for
      # @param opts [Hash] extra parameters to send with your request
      #
      # @return [Hash]
      #
      def get_frequently_bought_together(queries, opts = {})
        get_recommendations(
          set_query_models(queries.map { |q| symbolize_hash(q) }, BOUGHT_TOGETHER),
          opts
        )
      end

      private

      # Format the recommendation queries
      #
      # @param queries [Array<Hash>] the queries to retrieve recommendations for
      #
      # @return [Array<Hash>]
      #
      def format_recommendation_queries(queries)
        queries.map do |query|
          query[:threshold] = 0 unless query[:threshold].is_a? Numeric
          query.delete(:fallbackParameters) if query[:model] == BOUGHT_TOGETHER

          query
        end
      end

      # Force the queries to target a specific model
      #
      # @param queries [Array<Hash>] the queries to change
      # @param model [String] the model to enforce
      #
      # @return [Array<Hash>]
      #
      def set_query_models(queries, model)
        queries.map do |query|
          query[:model] = model
          query
        end
      end
    end
  end
end
