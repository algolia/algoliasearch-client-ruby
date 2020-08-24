module Algolia
  module Insights
    class Client
      include Helpers
      extend Forwardable

      def_delegators :@transporter, :read, :write

      def initialize(insights_config, opts = {})
        @config      = insights_config
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
        config = Insights::Config.new(app_id: app_id, api_key: api_key)
        create_with_config(config)
      end

      def self.create_with_config(config)
        new(config)
      end

      def user(user_token)
        UserClient.new(self, user_token)
      end

      def send_event(event, opts = {})
        send_events([event], opts)
      end

      def send_events(events, opts = {})
        write(:POST, '/1/events', { events: events }, opts)
      end
    end

    class UserClient
      def initialize(insights_client, user_token)
        @insights_client = insights_client
        @user_token      = user_token
      end

      def clicked_object_ids(event_name, index_name, object_ids, opts = {})
        @insights_client.send_event({
          eventType: 'click',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          objectIds: object_ids
        }, opts)
      end

      def clicked_object_ids_after_search(event_name, index_name,
        object_ids, positions, query_id, opts = {})
        @insights_client.send_event({
          eventType: 'click',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          objectIds: object_ids,
          positions: positions,
          queryId: query_id
        }, opts)
      end

      def clicked_filters(event_name, index_name, filters, opts = {})
        @insights_client.send_event({
          eventType: 'click',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          filters: filters
        }, opts)
      end

      def converted_object_ids(event_name, index_name, object_ids, opts = {})
        @insights_client.send_event({
          eventType: 'conversion',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          objectIds: object_ids
        }, opts)
      end

      def converted_object_ids_after_search(event_name, index_name,
        object_ids, query_id, opts = {})
        @insights_client.send_event({
          eventType: 'conversion',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          objectIds: object_ids,
          queryId: query_id
        }, opts)
      end

      def converted_filters(event_name, index_name, filters, opts = {})
        @insights_client.send_event({
          eventType: 'conversion',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          filters: filters
        }, opts)
      end

      def viewed_object_ids(event_name, index_name, object_ids, opts = {})
        @insights_client.send_event({
          eventType: 'view',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          objectIds: object_ids
        }, opts)
      end

      def viewed_filters(event_name, index_name, filters, opts = {})
        @insights_client.send_event({
          eventType: 'view',
          eventName: event_name,
          index: index_name,
          userToken: @user_token,
          filters: filters
        }, opts)
      end
    end
  end
end
