module Algolia
  module Search
    # Class Index
    class Index
      include CallType
      include Helpers
      extend Forwardable

      attr_reader :index_name, :transporter, :config

      def_delegators :@transporter, :read, :write

      # Initialize an index
      #
      # @param index_name [String] name of the index
      # @param transporter [nil, Object] transport object used for the connection
      # @param config [nil, Config] a Config object which contains your APP_ID and API_KEY
      #
      def initialize(index_name, transporter, config)
        @index_name  = index_name
        @transporter = transporter
        @config      = config
      end

      # # # # # # # # # # # # # # # # # # # # #
      # MISC
      # # # # # # # # # # # # # # # # # # # # #

      # Wait the publication of a task on the server.
      # All server task are asynchronous and you can check with this method that the task is published.
      #
      # @param task_id the id of the task returned by server
      # @param time_before_retry the time in milliseconds before retry (default = 100ms)
      # @param opts contains extra parameters to send with your query
      #
      def wait_task(task_id, time_before_retry = Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts = {})
        loop do
          status = get_task_status(task_id, opts)
          if status == 'published'
            return
          end
          sleep(time_before_retry / 1000)
        end
      end

      # Check the status of a task on the server.
      # All server task are asynchronous and you can check the status of a task with this method.
      #
      # @param task_id the id of the task returned by server
      # @param opts contains extra parameters to send with your query
      #
      def get_task_status(task_id, opts = {})
        res    = read(:GET, path_encode('/1/indexes/%s/task/%s', @index_name, task_id), {}, opts)
        status = get_option(res, 'status')
        status
      end

      # Delete the index content
      #
      # @param opts contains extra parameters to send with your query
      #
      def clear_objects(opts = {})
        write(:POST, path_encode('/1/indexes/%s/clear', @index_name), {}, opts)
      end

      # Delete the index content and wait for operation to finish
      #
      # @param opts contains extra parameters to send with your query
      #
      def clear_objects!(opts = {})
        res     = write(:POST, path_encode('/1/indexes/%s/clear', @index_name), opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def delete(opts = {})
        write(:DELETE, path_encode('/1/indexes/%s', @index_name), opts)
      end

      def delete!(opts = {})
        res     = write(:DELETE, path_encode('/1/indexes/%s', @index_name), opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # Find object by the given condition.
      #
      # Options can be passed in request_options body:
      #  - query (string): pass a query
      #  - paginate (bool): choose if you want to iterate through all the
      # documents (true) or only the first page (false). Default is true.
      # The function takes a block to filter the results from search query
      # Usage example:
      #  index.find_object({'query' => '', 'paginate' => true}) {|obj| obj.key?('company') and obj['company'] == 'Apple'}
      #
      # @param opts contains extra parameters to send with your query
      #
      # @return [Hash|AlgoliaHttpError] the matching object and its position in the result set
      #
      # TODO: use lambda
      def find_object(opts = {})
        request_options = symbolize_hash(opts)
        paginate        = true
        page            = 0

        query = request_options[:query] || ''
        request_options.delete(:query)

        if request_options.has_key? :paginate
          paginate = request_options[:paginate]
        end

        request_options.delete(:paginate)

        loop do
          request_options[:page] = page
          res                    = search(query, request_options)

          if block_given?
            res[:hits].each_with_index do |hit, i|
              if yield(hit)
                return {
                  object: hit,
                  position: i,
                  page: page
                }
              end
            end
          end

          has_next_page = page + 1 < res[:nbPages]
          if !paginate || !has_next_page
            raise AlgoliaHttpError.new(404, 'Object not found')
          end

          page += 1
        end
      end

      #
      # Retrieve the given object position in a set of results.
      #
      # @param [Array] objects the result set to browse
      # @param [String] object_id the object to look for
      #
      # @return [Integer] position of the object, or -1 if it's not in the array
      #
      def self.get_object_position(objects, object_id)
        hits = get_option(objects, 'hits')
        hits.find_index { |hit| get_option(hit, 'objectID') == object_id } || -1
      end

      def copy_to(name, opts = {})
        write(:POST, path_encode('/1/indexes/%s/operation', @index_name), { operation: 'copy', destination: name }, opts)
      end

      def move_to(name, opts = {})
        write(:POST, path_encode('/1/indexes/%s/operation', @index_name), { operation: 'move', destination: name }, opts)
      end

      # # # # # # # # # # # # # # # # # # # # #
      # INDEXING
      # # # # # # # # # # # # # # # # # # # # #

      def get_object(object_id, opts = {})
        read(:GET, path_encode('/1/indexes/%s/%s', @index_name, object_id), {}, opts)
      end

      def get_objects(object_ids, opts = {})
        request_options        = symbolize_hash(opts)
        attributes_to_retrieve = get_option(request_options, 'attributesToRetrieve')
        request_options.delete(:attributesToRetrieve)

        requests = []
        object_ids.each do |object_id|
          request = { indexName: @index_name, objectID: object_id.to_s }

          if attributes_to_retrieve
            request[:attributesToRetrieve] = attributes_to_retrieve
          end

          requests.push(request)
        end

        read(:POST, '/1/indexes/*/objects', { 'requests': requests }, opts)
      end

      # Override the content of an object
      #
      # @param object [Hash] the object to save
      # @param opts [Hash] contains extra parameters to send with your query
      #
      def save_object(object, opts = {})
        save_objects([object], opts)
      end

      # Override the content of an object and wait for operation to finish
      #
      # @param object [Hash] the object to save
      # @param opts [Hash] contains extra parameters to send with your query
      #
      def save_object!(object, opts = {})
        res     = save_objects([object], opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # Override the content of several objects
      #
      # @param objects the array of objects to save
      # @param opts contains extra parameters to send with your query
      #
      def save_objects(objects, opts = {})
        request_options    = symbolize_hash(opts)
        generate_object_id = request_options[:auto_generate_object_id_if_not_exist] || false
        request_options.delete(:auto_generate_object_id_if_not_exist)
        if generate_object_id
          raw_batch(chunk('addObject', objects), request_options)
        else
          raw_batch(chunk('updateObject', objects, true), request_options)
        end
      end

      # Override the content of several objects and wait for operation to finish
      #
      # @param objects the array of objects to save
      # @param opts contains extra parameters to send with your query
      #
      def save_objects!(objects, opts = {})
        request_options    = symbolize_hash(opts)
        generate_object_id = request_options[:auto_generate_object_id_if_not_exist] || false
        request_options.delete(:auto_generate_object_id_if_not_exist)
        res                = if generate_object_id
          raw_batch(chunk('addObject', objects), request_options)
        else
          raw_batch(chunk('updateObject', objects, true), request_options)
        end
        task_id            = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, request_options)
        res
      end

      def partial_update_object(object, opts = {})
        partial_update_objects([object], opts)
      end

      def partial_update_object!(object, opts = {})
        res     = partial_update_objects([object], opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def partial_update_objects(objects, opts = {})
        generate_object_id = false
        request_options    = symbolize_hash(opts)
        if get_option(request_options, 'createIfNotExists')
          generate_object_id = true
          request_options.delete(:createIfNotExists)
        end

        if generate_object_id
          raw_batch(chunk('partialUpdateObject', objects), request_options)
        else
          raw_batch(chunk('partialUpdateObjectNoCreate', objects), request_options)
        end
      end

      def partial_update_objects!(objects, opts = {})
        generate_object_id = false
        request_options    = symbolize_hash(opts)
        if get_option(request_options, 'createIfNotExists')
          generate_object_id = true
          request_options.delete(:createIfNotExists)
        end

        res     = if generate_object_id
          raw_batch(chunk('partialUpdateObject', objects), request_options)
        else
          raw_batch(chunk('partialUpdateObjectNoCreate', objects), request_options)
        end
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, request_options)
        res
      end

      def delete_object(object_id, opts = {})
        delete_objects([object_id], opts)
      end

      def delete_object!(object_id, opts = {})
        res     = delete_objects([object_id], opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def delete_objects(object_ids, opts = {})
        objects = object_ids.map do |object_id|
          { objectID: object_id }
        end
        raw_batch(chunk('deleteObject', objects), opts)
      end

      def delete_objects!(object_ids, opts = {})
        objects = object_ids.map do |object_id|
          { objectID: object_id }
        end
        res     = raw_batch(chunk('deleteObject', objects), opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def delete_by(filters, opts = {})
        write(:POST, path_encode('/1/indexes/%s/deleteByQuery', @index_name), filters, opts)
      end

      # Send a batch request
      #
      # @param requests [Hash] hash containing the requests to batch
      # @param opts contains extra parameters to send with your query
      #
      def batch(requests, opts = {})
        raw_batch(requests, opts)
      end

      # Send a batch request and wait for operation to finish
      #
      # @param request [Hash] hash containing the requests to batch
      # @param opts contains extra parameters to send with your query
      #
      def batch!(requests, opts = {})
        res     = raw_batch(requests, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # # # # # # # # # # # # # # # # # # # # #
      # QUERY RULES
      # # # # # # # # # # # # # # # # # # # # #

      def get_rule(object_id, opts = {})
        read(:GET, path_encode('/1/indexes/%s/rules/%s', @index_name, object_id), {}, opts)
      end

      def save_rule(rule, opts = {})
        save_rules([rule], opts)
      end

      def save_rule!(rule, opts = {})
        res     = save_rules([rule], opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def save_rules(rules, opts = {})
        if rules.empty?
          return []
        end

        forward_to_replicas  = false
        clear_existing_rules = false
        request_options      = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end

        if request_options[:clearExistingRules]
          clear_existing_rules = true
          request_options.delete(:clearExistingRules)
        end

        rules.each do |rule|
          get_object_id(rule)
        end

        write(:POST, path_encode('/1/indexes/%s/rules/batch?', @index_name) + to_query_string({ forwardToReplicas: forward_to_replicas, clearExistingRules: clear_existing_rules }), rules, request_options)
      end

      def save_rules!(rules, opts = {})
        res     = save_rules(rules, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def clear_rules(opts = {})
        forward_to_replicas = false
        request_options     = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end
        write(:POST, path_encode('1/indexes/%s/rules/clear?', @index_name) + to_query_string({ forwardToReplicas: forward_to_replicas }), '', request_options)
      end

      def clear_rules!(opts = {})
        res     = clear_rules(opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def delete_rule(object_id, opts = {})
        forward_to_replicas = false
        request_options     = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end
        write(
          :DELETE,
          path_encode('1/indexes/%s/rules/%s?', @index_name, object_id) + to_query_string({ forwardToReplicas: forward_to_replicas }),
          '',
          request_options
        )
      end

      def delete_rule!(object_id, opts = {})
        res     = delete_rule(object_id, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # # # # # # # # # # # # # # # # # # # # #
      # SYNONYMS
      # # # # # # # # # # # # # # # # # # # # #

      def get_synonym(object_id, opts = {})
        read(:GET, path_encode('/1/indexes/%s/synonyms/%s', @index_name, object_id), {}, opts)
      end

      def save_synonym(synonym, opts = {})
        save_synonyms([synonym], opts)
      end

      def save_synonym!(synonym, opts = {})
        res     = save_synonyms([synonym], opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def save_synonyms(synonyms, opts = {})
        if synonyms.empty?
          return []
        end

        synonyms.each do |synonym|
          get_object_id(synonym)
        end

        forward_to_replicas       = false
        replace_existing_synonyms = false

        request_options = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end

        if request_options[:replaceExistingSynonyms]
          replace_existing_synonyms = true
          request_options.delete(:replaceExistingSynonyms)
        end
        write(
          :POST,
          path_encode('/1/indexes/%s/synonyms/batch?', @index_name) + to_query_string({ forwardToReplicas: forward_to_replicas, replaceExistingSynonyms: replace_existing_synonyms }),
          synonyms,
          request_options
        )
      end

      def save_synonyms!(synonyms, opts = {})
        res     = save_synonyms(synonyms, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def clear_synonyms(opts = {})
        forward_to_replicas = false
        request_options     = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end
        write(
          :POST,
          path_encode('1/indexes/%s/synonyms/clear?', @index_name) + to_query_string({ forwardToReplicas: forward_to_replicas }),
          '',
          request_options
        )
      end

      def clear_synonyms!(opts = {})
        res     = clear_synonyms(opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      def delete_synonym(object_id, opts = {})
        forward_to_replicas = false
        request_options     = symbolize_hash(opts)

        if request_options[:forwardToReplicas]
          forward_to_replicas = true
          request_options.delete(:forwardToReplicas)
        end
        write(
          :DELETE,
          path_encode('1/indexes/%s/synonyms/%s?', @index_name, object_id) + to_query_string({ forwardToReplicas: forward_to_replicas }),
          '',
          request_options
        )
      end

      def delete_synonym!(object_id, opts = {})
        res     = delete_synonym(object_id, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # # # # # # # # # # # # # # # # # # # # #
      # BROWSING
      # # # # # # # # # # # # # # # # # # # # #

      def browse_objects(opts = {}, &block)
        if block_given?
          ObjectIterator.new(@transporter, @index_name, opts).each(&block)
        else
          ObjectIterator.new(@transporter, @index_name, opts)
        end
      end

      def browse_rules(opts = {}, &block)
        if block_given?
          RuleIterator.new(@transporter, @index_name, opts).each(&block)
        else
          RuleIterator.new(@transporter, @index_name, opts)
        end
      end

      def browse_synonyms(opts = {}, &block)
        if block_given?
          SynonymIterator.new(@transporter, @index_name, opts).each(&block)
        else
          SynonymIterator.new(@transporter, @index_name, opts)
        end
      end

      # # # # # # # # # # # # # # # # # # # # #
      # REPLACING
      # # # # # # # # # # # # # # # # # # # # #

      def replace_all_objects(objects, opts = {})
        safe            = false
        request_options = symbolize_hash(opts)
        if request_options[:safe]
          safe = true
          request_options.delete(:safe)
        end

        tmp_index_name   = @index_name + '_tmp_' + rand(10000000).to_s
        copy_to_response = copy_to(tmp_index_name, request_options.merge({ scope: %w(settings synonyms rules) }))

        if safe
          task_id = get_option(copy_to_response, 'taskID')
          wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, request_options)
        end

        # TODO: consider create a new client with state of retry is shared
        tmp_client = Algolia::Search::Client.new(@config)
        tmp_index  = tmp_client.init_index(tmp_index_name)

        save_objects_response = tmp_index.save_objects(objects, request_options)

        if safe
          task_id = get_option(save_objects_response, 'taskID')
          tmp_index.wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, request_options)
        end

        move_to_response = tmp_index.move_to(@index_name)
        if safe
          task_id = get_option(move_to_response, 'taskID')
          wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, request_options)
        end

        # TODO: return ResponseObject if needed
      end

      def replace_all_objects!(objects, opts = {})
        replace_all_objects(objects, opts.merge(safe: true))
      end

      def replace_all_rules(rules, opts = {})
        request_options                      = symbolize_hash(opts)
        request_options[:clearExistingRules] = true

        save_rules(rules, request_options)
      end

      def replace_all_rules!(rules, opts = {})
        request_options                      = symbolize_hash(opts)
        request_options[:clearExistingRules] = true

        save_rules!(rules, request_options)
      end

      def replace_all_synonyms(synonyms, opts = {})
        request_options                           = symbolize_hash(opts)
        request_options[:replaceExistingSynonyms] = true

        save_synonyms(synonyms, request_options)
      end

      def replace_all_synonyms!(synonyms, opts = {})
        request_options                           = symbolize_hash(opts)
        request_options[:replaceExistingSynonyms] = true

        save_synonyms!(synonyms, request_options)
      end

      # # # # # # # # # # # # # # # # # # # # #
      # SEARCHING
      # # # # # # # # # # # # # # # # # # # # #

      # Perform a search on the index
      #
      # @param query the full text query
      # @param opts contains extra parameters to send with your query
      #
      # @return Algolia::Response
      #
      def search(query, opts = {})
        read(:POST, path_encode('/1/indexes/%s/query', @index_name), { 'query': query.to_s }, opts)
      end

      def search_for_facet_values(facet_name, facet_query, opts = {})
        read(:POST, path_encode('/1/indexes/%s/facets/%s/query', @index_name, facet_name),
             { 'facetQuery': facet_query }, opts)
      end

      def search_synonyms(query, opts = {})
        read(:POST, path_encode('/1/indexes/%s/synonyms/search', @index_name), { query: query.to_s }, opts)
      end

      def search_rules(query, opts = {})
        read(:POST, path_encode('/1/indexes/%s/rules/search', @index_name), { query: query.to_s }, opts)
      end

      # # # # # # # # # # # # # # # # # # # # #
      # SETTINGS
      # # # # # # # # # # # # # # # # # # # # #

      def get_settings(opts = {})
        read(:GET, path_encode('/1/indexes/%s/settings?', @index_name) + to_query_string({ getVersion: 2 }), {}, opts)
      end

      def set_settings(settings, opts = {})
        write(:PUT, path_encode('/1/indexes/%s/settings', @index_name), settings, opts)
      end

      def set_settings!(settings, opts = {})
        res     = write(:PUT, path_encode('/1/indexes/%s/settings', @index_name), settings, opts)
        task_id = get_option(res, 'taskID')
        wait_task(task_id, Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
        res
      end

      # # # # # # # # # # # # # # # # # # # # #
      # EXISTS
      # # # # # # # # # # # # # # # # # # # # #

      def exists
        begin
          get_settings
        rescue AlgoliaHttpError => e
          if e.code == 404
            return false
          end

          raise e
        end
        true
      end

      #
      # Aliases the exists method
      #
      alias_method :exists?, :exists

      # # # # # # # # # # # # # # # # # # # # #
      # PRIVATE
      # # # # # # # # # # # # # # # # # # # # #

      private

      # Check the passed object to determine if it's an array
      #
      # @param object [Object]
      #
      def check_array(object)
        raise AlgoliaError, 'argument must be an array of objects' unless object.is_a?(Array)
      end

      # Check the passed object
      #
      # @param object [Object]
      # @param in_array [Boolean] whether the object is an array or not
      #
      def check_object(object, in_array = false)
        case object
        when Array
          raise AlgoliaError, in_array ? 'argument must be an array of objects' : 'argument must not be an array'
        when String, Integer, Float, TrueClass, FalseClass, NilClass
          raise AlgoliaError, "argument must be an #{'array of' if in_array} object, got: #{object.inspect}"
        end
      end

      # Check if passed object has a objectID
      #
      # @param object [Object]
      # @param object_id [String]
      #
      def get_object_id(object, object_id = nil)
        check_object(object)
        object_id ||= object[:objectID] || object['objectID']
        raise AlgoliaError, "Missing 'objectID'" if object_id.nil?
        object_id
      end

      # Build a batch request
      #
      # @param action [String] action to perform on the engine
      # @param objects [Array] objects on which build the action
      # @param with_object_id [Boolean] if set to true, check if each object has an objectID set
      #
      def chunk(action, objects, with_object_id = false)
        check_array(objects)
        objects.map do |object|
            check_object(object, true)
            request            = { action: action, body: object }
            request[:objectID] = get_object_id(object).to_s if with_object_id
            request
        end
      end

      def raw_batch(requests, opts)
        write(:POST, path_encode('/1/indexes/%s/batch', @index_name), { requests: requests }, opts)
      end
    end
  end
end
