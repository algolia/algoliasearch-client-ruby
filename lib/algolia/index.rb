require 'algolia/client'
require 'algolia/error'

module Algolia

  class Index
    attr_accessor :name, :client

    def initialize(name, client = nil)
      self.name = name
      self.client = client || Algolia.client
    end

    # Delete an index
    #
    # return an hash of the form { "deletedAt" => "2013-01-18T15:33:13.556Z", "taskID" => "42" }
    def delete
      client.delete(Protocol.index_uri(name))
    end
    alias_method :delete_index, :delete

    # Delete an index and wait until the deletion has been processed
    #
    # return an hash of the form { "deletedAt" => "2013-01-18T15:33:13.556Z", "taskID" => "42" }
    def delete!
      res = delete
      wait_task(res['taskID'])
      res
    end
    alias_method :delete_index!, :delete!

    # Add an object in this index
    #
    # @param obj the object to add to the index.
    #  The object is represented by an associative array
    # @param objectID (optional) an objectID you want to attribute to this object
    #  (if the attribute already exist the old object will be overridden)
    def add_object(obj, objectID = nil)
      check_object obj
      if objectID.nil? || objectID.to_s.empty?
        client.post(Protocol.index_uri(name), obj.to_json)
      else
        client.put(Protocol.object_uri(name, objectID), obj.to_json)
      end
    end

    # Add an object in this index and wait end of indexing
    #
    # @param obj the object to add to the index.
    #  The object is represented by an associative array
    # @param objectID (optional) an objectID you want to attribute to this object
    #  (if the attribute already exist the old object will be overridden)
    def add_object!(obj, objectID = nil)
      res = add_object(obj, objectID)
      wait_task(res["taskID"])
      return res
    end

    # Add several objects in this index
    #
    # @param objs the array of objects to add inside the index.
    #  Each object is represented by an associative array
    def add_objects(objs)
      batch build_batch('addObject', objs, false)
    end

    # Add several objects in this index and wait end of indexing
    #
    # @param objs the array of objects to add inside the index.
    #  Each object is represented by an associative array
    def add_objects!(obj)
      res = add_objects(obj)
      wait_task(res["taskID"])
      return res
    end

    # Search inside the index
    #
    # @param query the full text query
    # @param args (optional) if set, contains an associative array with query parameters:
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
    def search(query, params = {})
      encoded_params = Hash[params.map { |k,v| [k.to_s, v.is_a?(Array) ? v.to_json : v] }]
      encoded_params[:query] = query
      client.post(Protocol.search_post_uri(name), { :params => Protocol.to_query(encoded_params) }.to_json, :search)
    end

    class IndexBrowser
      def initialize(client, name, params)
        @client = client
        @name = name
        @params = params
        @cursor = params[:cursor] || params['cursor'] || nil
      end

      def browse(&block)
        loop do
          answer = @client.get(Protocol.browse_uri(@name, @params.merge({ :cursor => @cursor })), :read)
          answer['hits'].each do |hit|
            if block.arity == 2
              yield hit, @cursor
            else
              yield hit
            end
          end
          @cursor = answer['cursor']
          break if @cursor.nil?
        end
      end
    end

    #
    # Browse all index content
    #
    # @param pageOrQueryParameters The hash of query parameters to use to browse
    #                              To browse from a specific cursor, just add a ":cursor" parameters
    #
    # @DEPRECATED:
    # @param pageOrQueryParameters Pagination parameter used to select the page to retrieve.
    # @param hitsPerPage: Pagination parameter used to select the number of hits per page. Defaults to 1000.
    #
    def browse(pageOrQueryParameters = nil, hitsPerPage = nil, &block)
      params = {}
      if pageOrQueryParameters.is_a?(Hash)
        params.merge!(pageOrQueryParameters)
      else
        params[:page] = pageOrQueryParameters unless pageOrQueryParameters.nil?
      end
      if hitsPerPage.is_a?(Hash)
        params.merge!(hitsPerPage)
      else
        params[:hitsPerPage] = hitsPerPage unless hitsPerPage.nil?
      end

      if block_given?
        IndexBrowser.new(client, name, params).browse(&block)
      else
        params[:page] ||= 0
        params[:hitsPerPage] ||= 1000
        client.get(Protocol.browse_uri(name, params), :read)
      end
    end

    #
    # Browse a single page from a specific cursor
    #
    def browse_from(cursor, hitsPerPage = 1000)
      client.get(Protocol.browse_uri(name, { :cursor => cursor, :hitsPerPage => hitsPerPage }), :read)
    end

    #
    # Get an object from this index
    #
    # @param objectID the unique identifier of the object to retrieve
    # @param attributesToRetrieve (optional) if set, contains the list of attributes to retrieve as an array of strings of a string separated by ","
    #
    def get_object(objectID, attributesToRetrieve = nil)
      attributesToRetrieve = attributesToRetrieve.join(',') if attributesToRetrieve.is_a?(Array)
      if attributesToRetrieve.nil?
        client.get(Protocol.object_uri(name, objectID, nil), :read)
      else
        client.get(Protocol.object_uri(name, objectID, {:attributes => attributesToRetrieve}), :read)
      end
    end

    #
    # Get a list of objects from this index
    #
    # @param objectIDs the array of unique identifier of the objects to retrieve
    # @param attributesToRetrieve (optional) if set, contains the list of attributes to retrieve as an array of strings of a string separated by ","
    #
    def get_objects(objectIDs, attributesToRetrieve = nil)
      attributesToRetrieve = attributesToRetrieve.join(',') if attributesToRetrieve.is_a?(Array)
      requests = objectIDs.map do |objectID|
        req = {:indexName => name, :objectID => objectID.to_s}
        req[:attributesToRetrieve] = attributesToRetrieve unless attributesToRetrieve.nil?
        req
      end
      client.post(Protocol.objects_uri, { :requests => requests }.to_json, :read)['results']
    end

    # Check the status of a task on the server.
    # All server task are asynchronous and you can check the status of a task with this method.
    #
    # @param taskID the id of the task returned by server
    #
    def get_task_status(taskID)
      client.get(Protocol.task_uri(name, taskID), :read)["status"]
    end

    # Wait the publication of a task on the server.
    # All server task are asynchronous and you can check with this method that the task is published.
    #
    # @param taskID the id of the task returned by server
    # @param timeBeforeRetry the time in milliseconds before retry (default = 100ms)
    #
    def wait_task(taskID, timeBeforeRetry = 100)
      loop do
        status = get_task_status(taskID)
        if status == "published"
          return
        end
        sleep(timeBeforeRetry.to_f / 1000)
      end
    end

    # Override the content of an object
    #
    # @param obj the object to save
    # @param objectID the associated objectID, if nil 'obj' must contain an 'objectID' key
    #
    def save_object(obj, objectID = nil)
      client.put(Protocol.object_uri(name, get_objectID(obj, objectID)), obj.to_json)
    end

    # Override the content of object and wait end of indexing
    #
    # @param obj the object to save
    # @param objectID the associated objectID, if nil 'obj' must contain an 'objectID' key
    #
    def save_object!(obj, objectID = nil)
      res = save_object(obj, objectID)
      wait_task(res["taskID"])
      return res
    end

    # Override the content of several objects
    #
    # @param objs the array of objects to save, each object must contain an 'objectID' key
    #
    def save_objects(objs)
      batch build_batch('updateObject', objs, true)
    end

    # Override the content of several objects and wait end of indexing
    #
    # @param objs the array of objects to save, each object must contain an objectID attribute
    #
    def save_objects!(objs)
      res = save_objects(objs)
      wait_task(res["taskID"])
      return res
    end

    #
    # Update partially an object (only update attributes passed in argument)
    #
    # @param obj the object attributes to override
    # @param objectID the associated objectID, if nil 'obj' must contain an 'objectID' key
    # @param create_if_not_exits a boolean, if true creates the object if this one doesn't exist
    #
    def partial_update_object(obj, objectID = nil, create_if_not_exits = true)
      client.post(Protocol.partial_object_uri(name, get_objectID(obj, objectID), create_if_not_exits), obj.to_json)
    end

    #
    # Partially Override the content of several objects
    #
    # @param objs an array of objects to update (each object must contains a objectID attribute)
    # @param create_if_not_exits a boolean, if true create the objects if they don't exist
    #
    def partial_update_objects(objs, create_if_not_exits = true)
      if create_if_not_exits
        batch build_batch('partialUpdateObject', objs, true)
      else
        batch build_batch('partialUpdateObjectNoCreate', objs, true)
      end
    end

    #
    # Partially Override the content of several objects and wait end of indexing
    #
    # @param objs an array of objects to update (each object must contains a objectID attribute)
    # @param create_if_not_exits a boolean, if true create the objects if they don't exist
    #
    def partial_update_objects!(objs, create_if_not_exits = true)
      res = partial_update_objects(objs, create_if_not_exits)
      wait_task(res["taskID"])
      return res
    end

    #
    # Update partially an object (only update attributes passed in argument) and wait indexing
    #
    # @param obj the attributes to override
    # @param objectID the associated objectID, if nil 'obj' must contain an 'objectID' key
    # @param create_if_not_exits a boolean, if true creates the object if this one doesn't exist
    #
    def partial_update_object!(obj, objectID = nil, create_if_not_exits = true)
      res = partial_update_object(obj, objectID, create_if_not_exits)
      wait_task(res["taskID"])
      return res
    end

    #
    # Delete an object from the index
    #
    # @param objectID the unique identifier of object to delete
    #
    def delete_object(objectID)
      raise ArgumentError.new('objectID must not be blank') if objectID.nil? || objectID == ''
      client.delete(Protocol.object_uri(name, objectID))
    end

    #
    # Delete an object from the index and wait end of indexing
    #
    # @param objectID the unique identifier of object to delete
    #
    def delete_object!(objectID)
      res = delete_object(objectID)
      wait_task(res["taskID"])
      return res
    end

    #
    # Delete several objects
    #
    # @param objs an array of objectIDs
    #
    def delete_objects(objs)
      check_array objs
      batch build_batch('deleteObject', objs.map { |objectID| { :objectID => objectID } }, false)
    end

    #
    # Delete several objects and wait end of indexing
    #
    # @param objs an array of objectIDs
    #
    def delete_objects!(objs)
      res = delete_objects(objs)
      wait_task(res["taskID"])
      return res
    end

    #
    # Delete all objects matching a query
    #
    # @param query the query string
    # @param params the optional query parameters
    #
    def delete_by_query(query, params = nil)
      raise ArgumentError.new('query cannot be nil, use the `clear` method to wipe the entire index') if query.nil? && params.nil?
      params ||= {}
      params.delete(:hitsPerPage)
      params.delete('hitsPerPage')
      params.delete(:attributesToRetrieve)
      params.delete('attributesToRetrieve')

      params[:hitsPerPage] = 1000
      params[:distinct] = false
      params[:attributesToRetrieve] = ['objectID']
      last_task = nil
      loop do
        res = search(query, params)
        break if res['hits'].empty?
        last_task = delete_objects(res['hits'].map { |h| h['objectID'] })
        break if res['hits'].size < 1000
        wait_task(last_task['taskID'])
      end
      last_task
    end

    #
    # Delete all objects matching a query and wait end of indexing
    #
    # @param query the query string
    # @param params the optional query parameters
    #
    def delete_by_query!(query, params = nil)
      res = delete_by_query(query, params)
      wait_task(res['taskID']) if res
      res
    end

    #
    # Delete the index content
    #
    #
    def clear
      client.post(Protocol.clear_uri(name))
    end
    alias_method :clear_index, :clear

    #
    # Delete the index content and wait end of indexing
    #
    def clear!
      res = clear
      wait_task(res["taskID"])
      return res
    end
    alias_method :clear_index!, :clear!

    #
    # Set settings for this index
    #
    def set_settings(new_settings, options = {})
      client.put(Protocol.settings_uri(name, options), new_settings.to_json)
    end

    # Set settings for this index and wait end of indexing
    #
    def set_settings!(new_settings, options = {})
      res = set_settings(new_settings, options)
      wait_task(res["taskID"])
      return res
    end

    # Get settings of this index
    def get_settings(options = {})
      options['getVersion'] = 2 if !options[:getVersion] && !options['getVersion']
      client.get("#{Protocol.settings_uri(name, options)}", :read)
    end

    # List all existing user keys with their associated ACLs
    def list_api_keys
      client.get(Protocol.index_keys_uri(name), :read)
    end

    # Get ACL of a user key
    def get_api_key(key)
      client.get(Protocol.index_key_uri(name, key), :read)
    end

    #
    #  Create a new user key
    #
    #  @param obj can be two different parameters:
    #        The list of parameters for this key. Defined by a NSDictionary that
    #        can contains the following values:
    #          - acl: array of string
    #          - validity: int
    #          - referers: array of string
    #          - description: string
    #          - maxHitsPerQuery: integer
    #          - queryParameters: string
    #          - maxQueriesPerIPPerHour: integer
    #        Or the list of ACL for this key. Defined by an array of NSString that
    #        can contains the following values:
    #          - search: allow to search (https and http)
    #          - addObject: allows to add/update an object in the index (https only)
    #          - deleteObject : allows to delete an existing object (https only)
    #          - deleteIndex : allows to delete index content (https only)
    #          - settings : allows to get index settings (https only)
    #          - editSettings : allows to change index settings (https only)
    #  @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    #  @param maxQueriesPerIPPerHour the maximum number of API calls allowed from an IP address per hour (0 means unlimited)
    #  @param maxHitsPerQuery  the maximum number of hits this API key can retrieve in one call (0 means unlimited)
    #
    def add_api_key(obj, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0)
      if obj.instance_of? Array
        params = {
          :acl => obj
        }
      else
        params = obj
      end
      if validity != 0
        params["validity"] = validity.to_i
      end
      if maxQueriesPerIPPerHour != 0
        params["maxQueriesPerIPPerHour"] = maxQueriesPerIPPerHour.to_i
      end
      if maxHitsPerQuery != 0
        params["maxHitsPerQuery"] = maxHitsPerQuery.to_i
      end
      client.post(Protocol.index_keys_uri(name), params.to_json)
    end

    #
    #  Update a user key
    #
    #  @param obj can be two different parameters:
    #        The list of parameters for this key. Defined by a NSDictionary that
    #        can contains the following values:
    #          - acl: array of string
    #          - validity: int
    #          - referers: array of string
    #          - description: string
    #          - maxHitsPerQuery: integer
    #          - queryParameters: string
    #          - maxQueriesPerIPPerHour: integer
    #        Or the list of ACL for this key. Defined by an array of NSString that
    #        can contains the following values:
    #          - search: allow to search (https and http)
    #          - addObject: allows to add/update an object in the index (https only)
    #          - deleteObject : allows to delete an existing object (https only)
    #          - deleteIndex : allows to delete index content (https only)
    #          - settings : allows to get index settings (https only)
    #          - editSettings : allows to change index settings (https only)
    #  @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    #  @param maxQueriesPerIPPerHour the maximum number of API calls allowed from an IP address per hour (0 means unlimited)
    #  @param maxHitsPerQuery  the maximum number of hits this API key can retrieve in one call (0 means unlimited)
    #
    def update_api_key(key, obj, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0)
      if obj.instance_of? Array
        params = {
          :acl => obj
        }
      else
        params = obj
      end
      if validity != 0
        params["validity"] = validity.to_i
      end
      if maxQueriesPerIPPerHour != 0
        params["maxQueriesPerIPPerHour"] = maxQueriesPerIPPerHour.to_i
      end
      if maxHitsPerQuery != 0
        params["maxHitsPerQuery"] = maxHitsPerQuery.to_i
      end
      client.put(Protocol.index_key_uri(name, key), params.to_json)
    end


    # Delete an existing user key
    def delete_api_key(key)
      client.delete(Protocol.index_key_uri(name, key))
    end

    # Send a batch request
    def batch(request)
      client.post(Protocol.batch_uri(name), request.to_json, :batch)
    end

    # Send a batch request and wait the end of the indexing
    def batch!(request)
      res = batch(request)
      wait_task(res['taskID'])
      res
    end

    # Search for facet values
    #
    # @param facet Name of the facet to search. It must have been declared in the
    #       index's`attributesForFaceting` setting with the `searchable()` modifier.
    # @param text Text to search for in the facet's values
    # @param query An optional query to take extra search parameters into account.
    #       These parameters apply to index objects like in a regular search query.
    #       Only facet values contained in the matched objects will be returned.
    def search_for_facet_values(facet, text, query = {})
      params = query.clone
      params['facetQuery'] = text
      client.post(Protocol.search_facet_uri(name, facet), params.to_json)
    end

    # deprecated
    alias_method :search_facet, :search_for_facet_values

    # Perform a search with disjunctive facets generating as many queries as number of disjunctive facets
    #
    # @param query the query
    # @param disjunctive_facets the array of disjunctive facets
    # @param params a hash representing the regular query parameters
    # @param refinements a hash ("string" -> ["array", "of", "refined", "values"]) representing the current refinements
    #                    ex: { "my_facet1" => ["my_value1", ["my_value2"], "my_disjunctive_facet1" => ["my_value1", "my_value2"] }
    def search_disjunctive_faceting(query, disjunctive_facets, params = {}, refinements = {})
      raise ArgumentError.new('Argument "disjunctive_facets" must be a String or an Array') unless disjunctive_facets.is_a?(String) || disjunctive_facets.is_a?(Array)
      raise ArgumentError.new('Argument "refinements" must be a Hash of Arrays') if !refinements.is_a?(Hash) || !refinements.select { |k, v| !v.is_a?(Array) }.empty?

      # extract disjunctive facets & associated refinements
      disjunctive_facets = disjunctive_facets.split(',') if disjunctive_facets.is_a?(String)
      disjunctive_refinements = {}
      refinements.each do |k, v|
        disjunctive_refinements[k] = v if disjunctive_facets.include?(k) || disjunctive_facets.include?(k.to_s)
      end

      # build queries
      queries = []
      ## hits + regular facets query
      filters = []
      refinements.to_a.each do |k, values|
        r = values.map { |v| "#{k}:#{v}" }
        if disjunctive_refinements[k.to_s] || disjunctive_refinements[k.to_sym]
          # disjunctive refinements are ORed
          filters << r
        else
          # regular refinements are ANDed
          filters += r
        end
      end
      queries << params.merge({ :index_name => self.name, :query => query, :facetFilters => filters })
      ## one query per disjunctive facet (use all refinements but the current one + hitsPerPage=1 + single facet)
      disjunctive_facets.each do |disjunctive_facet|
        filters = []
        refinements.each do |k, values|
          if k.to_s != disjunctive_facet.to_s
            r = values.map { |v| "#{k}:#{v}" }
            if disjunctive_refinements[k.to_s] || disjunctive_refinements[k.to_sym]
              # disjunctive refinements are ORed
              filters << r
            else
              # regular refinements are ANDed
              filters += r
            end
          end
        end
        queries << params.merge({
          :index_name => self.name,
          :query => query,
          :page => 0,
          :hitsPerPage => 1,
          :attributesToRetrieve => [],
          :attributesToHighlight => [],
          :attributesToSnippet => [],
          :facets => disjunctive_facet,
          :facetFilters => filters,
          :analytics => false
        })
      end
      answers = client.multiple_queries(queries)

      # aggregate answers
      ## first answer stores the hits + regular facets
      aggregated_answer = answers['results'][0]
      ## others store the disjunctive facets
      aggregated_answer['disjunctiveFacets'] = {}
      answers['results'].each_with_index do |a, i|
        next if i == 0
        a['facets'].each do |facet, values|
          ## add the facet to the disjunctive facet hash
          aggregated_answer['disjunctiveFacets'][facet] = values
          ## concatenate missing refinements
          (disjunctive_refinements[facet.to_s] || disjunctive_refinements[facet.to_sym] || []).each do |r|
            if aggregated_answer['disjunctiveFacets'][facet][r].nil?
              aggregated_answer['disjunctiveFacets'][facet][r] = 0
            end
          end
        end
      end

      aggregated_answer
    end

    #
    # Alias of Algolia.list_indexes
    #
    def Index.all
      Algolia.list_indexes
    end

    # Search synonyms
    #
    # @param query the query
    # @param params an optional hash of :type, :page, :hitsPerPage
    def search_synonyms(query, params = {})
      type = params[:type] || params['type']
      type = type.join(',') if type.is_a?(Array)
      page = params[:page] || params['page'] || 0
      hits_per_page = params[:hitsPerPage] || params['hitsPerPage'] || 20
      params = {
        :query => query,
        :type => type.to_s,
        :page => page,
        :hitsPerPage => hits_per_page
      }
      client.post(Protocol.search_synonyms_uri(name), params.to_json, :read)
    end

    # Get a synonym
    #
    # @param objectID the synonym objectID
    def get_synonym(objectID)
      client.get(Protocol.synonym_uri(name, objectID), :read)
    end

    # Delete a synonym
    #
    # @param objectID the synonym objectID
    # @param forward_to_replicas should we forward the delete to replica indices
    def delete_synonym(objectID, forward_to_replicas = false)
      client.delete("#{Protocol.synonym_uri(name, objectID)}?forwardToReplicas=#{forward_to_replicas}", :write)
    end

    # Delete a synonym and wait the end of indexing
    #
    # @param objectID the synonym objectID
    # @param forward_to_replicas should we forward the delete to replica indices
    def delete_synonym!(objectID, forward_to_replicas = false)
      res = delete_synonym(objectID, forward_to_replicas)
      wait_task(res["taskID"])
      return res
    end

    # Save a synonym
    #
    # @param objectID the synonym objectID
    # @param synonym the synonym
    # @param forward_to_replicas should we forward the delete to replica indices
    def save_synonym(objectID, synonym, forward_to_replicas = false)
      client.put("#{Protocol.synonym_uri(name, objectID)}?forwardToReplicas=#{forward_to_replicas}", synonym.to_json, :write)
    end

    # Save a synonym and wait the end of indexing
    #
    # @param objectID the synonym objectID
    # @param synonym the synonym
    # @param forward_to_replicas should we forward the delete to replica indices
    def save_synonym!(objectID, synonym, forward_to_replicas = false)
      res = save_synonym(objectID, synonym, forward_to_replicas)
      wait_task(res["taskID"])
      return res
    end

    # Clear all synonyms
    #
    # @param forward_to_replicas should we forward the delete to replica indices
    def clear_synonyms(forward_to_replicas = false)
      client.post("#{Protocol.clear_synonyms_uri(name)}?forwardToReplicas=#{forward_to_replicas}", :write)
    end

    # Clear all synonyms and wait the end of indexing
    #
    # @param forward_to_replicas should we forward the delete to replica indices
    def clear_synonyms!(forward_to_replicas = false)
      res = clear_synonyms(forward_to_replicas)
      wait_task(res["taskID"])
      return res
    end

    # Add/Update an array of synonyms
    #
    # @param synonyms the array of synonyms to add/update
    # @param forward_to_replicas should we forward the delete to replica indices
    # @param replace_existing_synonyms should we replace the existing synonyms before adding the new ones
    def batch_synonyms(synonyms, forward_to_replicas = false, replace_existing_synonyms = false)
      client.post("#{Protocol.batch_synonyms_uri(name)}?forwardToReplicas=#{forward_to_replicas}&replaceExistingSynonyms=#{replace_existing_synonyms}", synonyms.to_json, :batch)
    end

    # Add/Update an array of synonyms and wait the end of indexing
    #
    # @param synonyms the array of synonyms to add/update
    # @param forward_to_replicas should we forward the delete to replica indices
    # @param replace_existing_synonyms should we replace the existing synonyms before adding the new ones
    def batch_synonyms!(synonyms, forward_to_replicas = false, replace_existing_synonyms = false)
      res = batch_synonyms(synonyms, forward_to_replicas, replace_existing_synonyms)
      wait_task(res["taskID"])
      return res
    end

    # Deprecated
    alias_method :get_user_key, :get_api_key
    alias_method :list_user_keys, :list_api_keys
    alias_method :add_user_key, :add_api_key
    alias_method :update_user_key, :update_api_key
    alias_method :delete_user_key, :delete_api_key

    private
    def check_array(objs)
      raise ArgumentError.new("argument must be an array of objects") if !objs.is_a?(Array)
    end

    def check_object(obj, in_array = false)
      case obj
      when Array
        raise ArgumentError.new(in_array ? "argument must be an array of objects" : "argument must not be an array")
      when String, Integer, Float, TrueClass, FalseClass, NilClass
        raise ArgumentError.new("argument must be an #{'array of' if in_array} object, got: #{obj.inspect}")
      else
        # ok
      end
    end

    def get_objectID(obj, objectID = nil)
      check_object obj
      objectID ||= obj[:objectID] || obj["objectID"]
      raise ArgumentError.new("Missing 'objectID'") if objectID.nil?
      return objectID
    end

    def build_batch(action, objs, with_object_id = false)
      check_array objs
      {
        :requests => objs.map { |obj|
          check_object obj, true
          h = { :action => action, :body => obj }
          h[:objectID] = get_objectID(obj).to_s if with_object_id
          h
        }
      }
    end

    def sanitized_delete_by_query_params(params)
      params ||= {}
      params.delete(:hitsPerPage)
      params.delete('hitsPerPage')
      params.delete(:attributesToRetrieve)
      params.delete('attributesToRetrieve')
      params
    end
  end
end
