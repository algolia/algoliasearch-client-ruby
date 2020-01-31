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
    # @param query the full text query
    # @param search_params (optional) if set, contains an hash with search parameters:
    # - page: (integer) Pagination parameter used to select the page to retrieve.
    #                   Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
    # - hitsPerPage: (integer) Pagination parameter used to select the number of hits per page. Defaults to 20.
    # - attributesToRetrieve: a string that contains the list of object attributes you want to retrieve (let you minimize the answer size).
    #   Attributes are separated with a comma (for example "name,address").
    #   You can also use a string array encoding (for example ["name","address"]).
    #   By default, all attributes are retrieved. You can also use '*' to retrieve all values when an attributesToRetrieve setting is specified for your index.
    # - attributesToHighlight: a string that contains the list of attributes you want to highlight according to the query.
    #   Attributes are separated by a comma. You can also use a string array encoding (for example ["name","address"]).
    #   If an attribute has no match for the query, the raw value is returned. By default all indexed text attributes are highlighted.
    #   You can use `*` if you want to highlight all textual attributes. Numerical attributes are not highlighted.
    #   A matchLevel is returned for each highlighted attribute and can contain:
    #      - full: if all the query terms were found in the attribute,
    #      - partial: if only some of the query terms were found,
    #      - none: if none of the query terms were found.
    # - attributesToSnippet: a string that contains the list of attributes to snippet alongside the number of words to return (syntax is `attributeName:nbWords`).
    #    Attributes are separated by a comma (Example: attributesToSnippet=name:10,content:10).
    #    You can also use a string array encoding (Example: attributesToSnippet: ["name:10","content:10"]). By default no snippet is computed.
    # - minWordSizefor1Typo: the minimum number of characters in a query word to accept one typo in this word. Defaults to 3.
    # - minWordSizefor2Typos: the minimum number of characters in a query word to accept two typos in this word. Defaults to 7.
    # - getRankingInfo: if set to 1, the result hits will contain ranking information in _rankingInfo attribute.
    # - aroundLatLng: search for entries around a given latitude/longitude (specified as two floats separated by a comma).
    #   For example aroundLatLng=47.316669,5.016670).
    #   You can specify the maximum distance in meters with the aroundRadius parameter (in meters) and the precision for ranking with aroundPrecision
    #   (for example if you set aroundPrecision=100, two objects that are distant of less than 100m will be considered as identical for "geo" ranking parameter).
    #   At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    # - insideBoundingBox: search entries inside a given area defined by the two extreme points of a rectangle (defined by 4 floats: p1Lat,p1Lng,p2Lat,p2Lng).
    #   For example insideBoundingBox=47.3165,4.9665,47.3424,5.0201).
    #   At indexing, you should specify geoloc of an object with the _geoloc attribute (in the form {"_geoloc":{"lat":48.853409, "lng":2.348800}})
    # - numericFilters: a string that contains the list of numeric filters you want to apply separated by a comma.
    #   The syntax of one filter is `attributeName` followed by `operand` followed by `value`. Supported operands are `<`, `<=`, `=`, `>` and `>=`.
    #   You can have multiple conditions on one attribute like for example numericFilters=price>100,price<1000.
    #   You can also use a string array encoding (for example numericFilters: ["price>100","price<1000"]).
    # - tagFilters: filter the query by a set of tags. You can AND tags by separating them by commas.
    #   To OR tags, you must add parentheses. For example, tags=tag1,(tag2,tag3) means tag1 AND (tag2 OR tag3).
    #   You can also use a string array encoding, for example tagFilters: ["tag1",["tag2","tag3"]] means tag1 AND (tag2 OR tag3).
    #   At indexing, tags should be added in the _tags** attribute of objects (for example {"_tags":["tag1","tag2"]}).
    # - facetFilters: filter the query by a list of facets.
    #   Facets are separated by commas and each facet is encoded as `attributeName:value`.
    #   For example: `facetFilters=category:Book,author:John%20Doe`.
    #   You can also use a string array encoding (for example `["category:Book","author:John%20Doe"]`).
    # - facets: List of object attributes that you want to use for faceting.
    #   Attributes are separated with a comma (for example `"category,author"` ).
    #   You can also use a JSON string array encoding (for example ["category","author"]).
    #   Only attributes that have been added in **attributesForFaceting** index setting can be used in this parameter.
    #   You can also use `*` to perform faceting on all attributes specified in **attributesForFaceting**.
    # - queryType: select how the query words are interpreted, it can be one of the following value:
    #    - prefixAll: all query words are interpreted as prefixes,
    #    - prefixLast: only the last word is interpreted as a prefix (default behavior),
    #    - prefixNone: no query word is interpreted as a prefix. This option is not recommended.
    # - optionalWords: a string that contains the list of words that should be considered as optional when found in the query.
    #   The list of words is comma separated.
    # - distinct: If set to 1, enable the distinct feature (disabled by default) if the attributeForDistinct index setting is set.
    #   This feature is similar to the SQL "distinct" keyword: when enabled in a query with the distinct=1 parameter,
    #   all hits containing a duplicate value for the attributeForDistinct attribute are removed from results.
    #   For example, if the chosen attribute is show_name and several hits have the same value for show_name, then only the best
    #   one is kept and others are removed.
    # @param opts contains extra parameters to send with your query
    #
    # @return Algoliasearch::Response
    #
    def search(query, search_params = {}, opts = {})
      encoded_params         = Helpers.params_to_hash(search_params)
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
    # @param autoGenerateObjectIDIfNotExist [Boolean] if set to true, an objectID will be automatically set on your object
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
    # @param objects the array of objects to save
    # @param autoGenerateObjectIDIfNotExist [Boolean] if set to true, an objectID will be automatically set on your objects
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
    # @param autoGenerateObjectIDIfNotExist [Boolean] if set to true, an objectID will be automatically set on your objects
    # @param opts contains extra parameters to send with your query
    #
    def save_objects!(objects, autoGenerateObjectIDIfNotExist = false, opts = {})
      res = save_objects(objects, autoGenerateObjectIDIfNotExist, opts)
      wait_task(res['taskID'], Defaults::WAIT_TASK_DEFAULT_TIME_BEFORE_RETRY, opts)
      res
    end

    # Delete the index content
    #
    # @param opts contains extra parameters to send with your query
    #
    def clear_objects(opts = {})
      @transporter.write(:POST, "#{@index_uri}/clear", {}, opts)
    end

    # Delete the index content and wait for the engine to treat the operation
    #
    # @param opts contains extra parameters to send with your query
    #
    def clear_objects!(opts = {})
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
    # @param request [Hash] hash containing the requests to batch
    # @param opts contains extra parameters to send with your query
    #
    def batch(request, opts = {})
      @transporter.write(:POST, "#{@index_uri}/batch", request, opts)
    end

    private

    # Check the passed object to determine if it's an array
    #
    # @param object [Object]
    #
    def check_array(object)
      raise ArgumentError, 'argument must be an array of objects' if !object.is_a?(Array)
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
