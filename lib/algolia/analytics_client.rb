module Algolia
  module Analytics
    class Client
      include Helpers
      extend Forwardable

      def_delegators :@transporter, :read, :write

      def initialize(analytics_config, opts = {})
        @config      = analytics_config
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
        config = Analytics::Config.new(app_id: app_id, api_key: api_key)
        new(config)
      end

      def self.create_with_config(config)
        new(config)
      end

      def add_ab_test(ab_test, opts = {})
        write(:POST, '2/abtests', ab_test, opts)
      end

      def get_ab_test(ab_test_id, opts = {})
        raise AlgoliaError, 'ab_test_id cannot be empty.' if ab_test_id.nil?

        read(:GET, path_encode('2/abtests/%s', ab_test_id), {}, opts)
      end

      def get_ab_tests(opts = {})
        read(:GET, '2/abtests/', {}, opts)
      end
    end
  end
end
