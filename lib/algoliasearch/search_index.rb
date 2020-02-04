module Algolia
  module Search
    # Class Index
    class Index
      include CallType

      attr_reader :index_name, :transporter, :config

      # Initialize an index
      #
      # @param index_name [String] name of the index
      # @param transporter [nil, Object] transport object used for the connection
      # @param config [nil, Config] a Config object which contains your APP_ID and API_KEY
      #
      def initialize(index_name, transporter, config)
        @index_name  = index_name
        @index_uri   = "/#{Defaults::VERSION}/indexes/#{CGI.escape(index_name)}"
        @transporter = transporter
        @config      = config
      end

      # Perform a search on the index
      #
      # @param query the full text query
      # @param search_params (optional)
      # @param opts contains extra parameters to send with your query
      #
      # @return Algolia::Response
      #
      def search(query, search_params: {}, opts: {})
        search_params[:query] = query
        @transporter.read(:POST, "#{@index_uri}/query", body: search_params, opts: opts)
      end

      def method_missing(method, *args, &block)
        if method.to_s.end_with?('!')
          string_method = method.to_s
          string_method.slice!('!')
          if respond_to?(string_method.to_sym)
            opts                   = {}
            args.each { |arg| opts = arg[:opts] if arg.is_a?(Hash) && arg.has_key?(:opts) }
            res                    = send(string_method.to_sym, *args)
            wait_task(res['taskID'], time_before_retry: Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts: opts)
            res
          else
            super
          end
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.end_with?('!') || super
      end

      # Override the content of an object
      #
      # @param object [Hash] the object to save
      # @param auto_generate_object_id_if_not_exist [Boolean] the associated objectID, if nil 'object' must contain an 'objectID' key
      # @param opts [Hash] contains extra parameters to send with your query
      #
      def save_object(object, auto_generate_object_id_if_not_exist: false, opts: {})
        save_objects([object], auto_generate_object_id_if_not_exist: auto_generate_object_id_if_not_exist, opts: opts)
      end

      #
      # Override the content of several objects
      #
      # @param objects the array of objects to save
      # @param auto_generate_object_id_if_not_exist [Boolean] if set to true, an objectID will be automatically set on your objects
      # @param opts contains extra parameters to send with your query
      #
      def save_objects(objects, auto_generate_object_id_if_not_exist: false, opts: {})
        if auto_generate_object_id_if_not_exist
          batch(build_batch('addObject', objects), opts: opts)
        else
          batch(build_batch('updateObject', objects, true), opts: opts)
        end
      end

      # Delete the index content
      #
      # @param opts contains extra parameters to send with your query
      #
      def clear_objects(opts: {})
        @transporter.write(:POST, "#{@index_uri}/clear", opts: opts)
      end

      # Wait the publication of a task on the server.
      # All server task are asynchronous and you can check with this method that the task is published.
      #
      # @param task_id the id of the task returned by server
      # @param time_before_retry the time in milliseconds before retry (default = 100ms)
      # @param opts contains extra parameters to send with your query
      #
      def wait_task(task_id, time_before_retry: Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts: {})
        loop do
          status = get_task_status(task_id, opts: opts)
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
      def get_task_status(task_id, opts: {})
        @transporter.read(:GET, "#{@index_uri}/task/#{task_id}", opts: opts)['status']
      end

      # Send a batch request
      #
      # @param request [Hash] hash containing the requests to batch
      # @param opts contains extra parameters to send with your query
      #
      def batch(request, opts: {})
        @transporter.write(:POST, "#{@index_uri}/batch", body: request, opts: opts)
      end

      private

      # Check the passed object to determine if it's an array
      #
      # @param object [Object]
      #
      def check_array(object)
        raise ArgumentError, 'argument must be an array of objects' unless object.is_a?(Array)
      end

      # Check the passed object
      #
      # @param object [Object]
      # @param in_array [Boolean] whether the object is an array or not
      #
      def check_object(object, in_array = false)
        case object
        when Array
          raise ArgumentError, in_array ? 'argument must be an array of objects' : 'argument must not be an array'
        when String, Integer, Float, TrueClass, FalseClass, NilClass
          raise ArgumentError, "argument must be an #{'array of' if in_array} object, got: #{object.inspect}"
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
        raise ArgumentError, "Missing 'objectID'" if object_id.nil?
        object_id
      end

      # Build a batch request
      #
      # @param action [String] action to perform on the engine
      # @param objects [Array] objects on which build the action
      # @param with_object_id [Boolean] if set to true, check if each object has an objectID set
      #
      def build_batch(action, objects, with_object_id = false)
        check_array(objects)
        {
          requests: objects.map do |object|
            check_object(object, true)
            h            = {action: action, body: object}
            h[:objectID] = get_object_id(object).to_s if with_object_id
            h
          end
        }
      end
    end
  end
end
