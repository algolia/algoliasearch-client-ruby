require 'faraday'

module Algolia
  module Search
    # Class Client
    class Client
      include Helpers
      extend Forwardable

      def_delegators :@transporter, :read, :write

      # Initialize a client to connect to Algolia
      #
      # @param search_config [Search::Config] a Search::Config object which contains your APP_ID and API_KEY
      # @option adapter [Object] adapter object used for the connection
      #
      def initialize(search_config, opts = {})
        @config      = search_config
        adapter      = opts[:adapter] || Defaults::ADAPTER
        logger       = opts[:logger] || LoggerHelper.create('debug.log')
        requester    = opts[:http_requester] || Defaults::REQUESTER_CLASS.new(adapter, logger)
        @transporter = Transport::Transport.new(@config, requester)
      end

      def self.create(app_id, api_key)
        config = Search::Config.new(app_id: app_id, api_key: api_key)
        new(config)
      end

      def wait_task(index_name, task_id, time_before_retry = WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts = {})
        loop do
          status = get_task_status(index_name, task_id, opts)
          if status == 'published'
            return
          end
          sleep(time_before_retry.to_f / 1000)
        end
      end

      # Check the status of a task on the server.
      # All server task are asynchronous and you can check the status of a task with this method.
      #
      # @param task_id the id of the task returned by server
      # @param opts contains extra parameters to send with your query
      #
      def get_task_status(index_name, task_id, opts = {})
        res = read(:GET, path_encode('/1/indexes/%s/task/%s', index_name, task_id), {}, opts)
        get_option(res, 'status')
      end

      # # # # # # # # # # # # # # # # # # # # #
      # MISC
      # # # # # # # # # # # # # # # # # # # # #

      # Initialize an index with a given name
      #
      # @param index_name [String] name of the index to init
      #
      # @return [Index] new Index instance
      #
      def init_index(index_name)
        index_name.strip!
        if index_name.empty?
          raise AlgoliaError, 'Please provide a valid index name'
        end
        Index.new(index_name, @transporter, @config)
      end

      def list_indexes(opts = {})
        read(:GET, '1/indexes', {}, opts)
      end

      def get_logs(opts = {})
        read(:GET, '1/logs', {}, opts)
      end

      # # # # # # # # # # # # # # # # # # # # #
      # COPY OPERATIONS
      # # # # # # # # # # # # # # # # # # # # #

      def copy_rules(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'rules'
        copy_index(src_index_name, dest_index_name, request_options)
      end

      def copy_rules!(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'rules'
        copy_index!(src_index_name, dest_index_name, request_options)
      end

      def copy_settings(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'settings'
        copy_index(src_index_name, dest_index_name, request_options)
      end

      def copy_settings!(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'settings'
        copy_index!(src_index_name, dest_index_name, request_options)
      end

      def copy_synonyms(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'synonyms'
        copy_index(src_index_name, dest_index_name, request_options)
      end

      def copy_synonyms!(src_index_name, dest_index_name, opts = {})
        request_options         = symbolize_hash(opts)
        request_options[:scope] = 'synonyms'
        copy_index!(src_index_name, dest_index_name, request_options)
      end

      def copy_index(src_index_name, dest_index_name, opts = {})
        write(:POST, path_encode('1/indexes/%s/operation', src_index_name), { operation: 'copy', destination: dest_index_name }, opts)
      end

      def copy_index!(src_index_name, dest_index_name, opts = {})
        res     = copy_index(src_index_name, dest_index_name)
        task_id = get_option(res, 'taskID')
        wait_task(dest_index_name, task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # # # # # # # # # # # # # # # # # # # # #
      # MOVE OPERATIONS
      # # # # # # # # # # # # # # # # # # # # #

      def move_index(src_index, dest_index, opts = {})
        # TODO
      end

      # # # # # # # # # # # # # # # # # # # # #
      # API KEY METHODS
      # # # # # # # # # # # # # # # # # # # # #

      def get_api_key(key_id, opts = {})
        read(:GET, path_encode('1/keys/%s', key_id), {}, opts)
      end

      def add_api_key(acl, opts = {})
        response = write(:POST, '1/keys', { acl: acl }, opts)

        AddApiKeyResponse.new(self, response)
      end

      def add_api_key!(acl, opts = {})
        response = add_api_key(acl)

        response.wait(opts)
      end

      def update_api_key(key, opts = {})
        request_options = symbolize_hash(opts)

        response = write(:PUT, path_encode('1/keys/%s', key), {}, request_options)

        UpdateApiKeyResponse.new(self, response, request_options)
      end

      def update_api_key!(key, opts = {})
        response = update_api_key(key, opts)

        response.wait(opts)
      end

      def delete_api_key(key, opts = {})
        response = write(:DELETE, path_encode('1/keys/%s', key), {}, opts)

        DeleteApiKeyResponse.new(self, response, key)
      end

      def delete_api_key!(key, opts = {})
        response = delete_api_key(key, opts)

        response.wait(opts)
      end

      def restore_api_key(key, opts = {})
        write(:POST, path_encode('1/keys/%s/restore', key), {}, opts)

        RestoreApiKeyResponse.new(self, key)
      end

      def restore_api_key!(key, opts = {})
        response = restore_api_key(key, opts)

        response.wait(opts)
      end

      def list_api_keys(opts = {})
        read(:GET, '1/keys', {}, opts)
      end

      def generate_secured_api_key(parent_key, restrictions, opts = {})
        # TODO
      end

      def get_secured_api_key_remaining_validity(secured_api_key)
        # TODO
      end

      # # # # # # # # # # # # # # # # # # # # #
      # MULTIPLE* METHODS
      # # # # # # # # # # # # # # # # # # # # #

      def multiple_batch(operations, opts = {})
        write(:POST, '1/indexes/*/batch', { requests: operations }, opts)
      end

      def multiple_get_objects(requests, opts = {})
        # TODO
      end

      def multiple_queries(queries, opts = {})
        # TODO
      end

      # # # # # # # # # # # # # # # # # # # # #
      # MCM METHODS
      # # # # # # # # # # # # # # # # # # # # #

      def assign_user_id(user_id, cluster_name, opts = {})
        request_options           = symbolize_hash(opts)
        request_options[:headers] = { 'X-Algolia-User-ID': user_id }

        write(:POST, '1/clusters/mapping', { cluster: cluster_name }, request_options)
      end

      def assign_user_ids(user_ids, cluster_name, opts = {})
        write(:POST, '1/clusters/mapping/batch', { cluster: cluster_name, users: user_ids }, opts)
      end

      def get_top_user_ids(opts = {})
        read(:GET, '1/clusters/mapping/top', {}, opts)
      end

      def get_user_id(user_id, opts = {})
        read(:GET, path_encode('1/clusters/mapping/%s', user_id), {}, opts)
      end

      def list_clusters(opts = {})
        read(:GET, '1/clusters', {}, opts)
      end

      def list_user_ids(opts = {})
        read(:GET, '1/clusters/mapping', {}, opts)
      end

      def remove_user_id(user_id, opts = {})
        request_options           = symbolize_hash(opts)
        request_options[:headers] = { 'X-Algolia-User-ID': user_id }

        write(:DELETE, '1/clusters/mapping', {}, request_options)
      end

      def search_user_ids(query, opts = {})
        read(:POST, '1/clusters/mapping/search', { query: query }, opts)
      end

      def pending_mappings?(opts = {})
        retrieve_mappings = false

        request_options = symbolize_hash(opts)
        if request_options.has_key?(:retrieveMappings)
          retrieve_mappings = request_options[:retrieveMappings]
          request_options.delete(:retrieveMappings)
        end

        read(:GET, '1/clusters/mapping/pending?' + to_query_string({ getClusters: retrieve_mappings }), {}, request_options)
      end

      #
      # Aliases the pending_mappings? method
      #
      alias_method :has_pending_mappings, :pending_mappings?
    end
  end
end
