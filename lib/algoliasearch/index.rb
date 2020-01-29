module Algoliasearch
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
    # @param query [String] query string provided for the search
    #
    # @return res
    #
    def search(query, search_params = {}, opts = {})
      encoded_params         = Helpers.to_hash(search_params)
      encoded_params[:query] = query
      @transporter.read(:POST, "#{@index_uri}/query", encoded_params, opts)
    end

    # Override the content of an object
    #
    # @param object [Hash] the object to save
    # @param autoGenerateObjectIDIfNotExist [Boolean] the associated objectID, if nil 'object' must contain an 'objectID' key
    # @param opts [Hash] contains extra parameters to send with your query
    #
    def save_object(object, autoGenerateObjectIDIfNotExist = false, opts = {})
      save_objects([object], autoGenerateObjectIDIfNotExist, opts)
    end

    # Override the content of an object and wait for the engine to treat the operation
    #
    # @param object [Hash] the object to save
    # @param autoGenerateObjectIDIfNotExist [Boolean] the associated objectID, if nil 'object' must contain an 'objectID' key
    # @param opts [Hash] contains extra parameters to send with your query
    #
    def save_object!(object, autoGenerateObjectIDIfNotExist = false, opts = {})
      res = save_object(object, autoGenerateObjectIDIfNotExist, opts)
      wait_task(res['taskID'], Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
      res
    end

    #
    # Override the content of several objects
    #
    # @param objects the array of objects to save, each object must contain an 'objectID' key
    # @param opts contains extra parameters to send with your query
    #
    def save_objects(objects, autoGenerateObjectIDIfNotExist = false, opts = {})
      if autoGenerateObjectIDIfNotExist
        batch(build_batch('addObject', objects), opts)
      else
        batch(build_batch('updateObject', objects, true), opts)
      end
    end

    # Override the content of several objects and wait for the engine to treat the operation
    #
    # @param objects the array of objects to save, each object must contain an objectID attribute
    # @param opts contains extra parameters to send with your query
    #
    def save_objects!(objects, opts = {})
      res = save_objects(objects, opts)
      wait_task(res['taskID'], Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
      res
    end

    # Delete the index content
    #
    # @param opts contains extra parameters to send with your query
    #
    def clear_objects(opts: {})
      @transporter.write(:POST, "#{@index_uri}/clear", {}, opts)
    end

    # Delete the index content and wait for the engine to treat the operation
    #
    # @param opts contains extra parameters to send with your query
    #
    def clear_objects!(opts: {})
      res = clear_objects(opts)
      wait_task(res['taskID'], Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
      res
    end

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
        sleep(time_before_retry.to_f / 1000)
      end
    end

    # Check the status of a task on the server.
    # All server task are asynchronous and you can check the status of a task with this method.
    #
    # @param task_id the id of the task returned by server
    # @param opts contains extra parameters to send with your query
    #
    def get_task_status(task_id, opts = {})
      @transporter.read(:GET, "#{@index_uri}/task/#{task_id}", {}, opts)['status']
    end

    # Send a batch request
    #
    def batch(request, opts = {})
      @transporter.write(:POST, "#{@index_uri}/batch", request, opts)
    end

    private

    # Check the passed object to determine if it's an array
    #
    def check_array(object)
      raise ArgumentError, 'argument must be an array of objects' if !object.is_a?(Array)
    end

    # Check the passed object
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
    def get_object_id(object, object_id = nil)
      check_object(object)
      object_id ||= object[:objectID] || object['objectID']
      raise ArgumentError, "Missing 'objectID'" if object_id.nil?
      object_id
    end

    # Build a batch request
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
