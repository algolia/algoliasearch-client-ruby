require 'algolia/client'
require 'algolia/error'

module Algolia
  
  class Index
    attr_accessor :name
    
    def initialize(name)
      self.name = name
    end
    
    # Delete an index
    #
    # return an hash of the form { "deletedAt" => "2013-01-18T15:33:13.556Z", "taskID" => "42" }
    def delete
      Algolia.client.delete(Protocol.index_uri(name))
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
        Algolia.client.post(Protocol.index_uri(name), obj.to_json)
      else
        Algolia.client.put(Protocol.object_uri(name, objectID), obj.to_json)        
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
      Algolia.client.get(Protocol.search_uri(name, query, encoded_params), Algolia.client.search_timeout)
    end

    #
    # Browse all index content
    #
    # @param page Pagination parameter used to select the page to retrieve.
    #             Page is zero-based and defaults to 0. Thus, to retrieve the 10th page you need to set page=9
    # @param hitsPerPage: Pagination parameter used to select the number of hits per page. Defaults to 1000.
    #
    def browse(page = 0, hitsPerPage = 1000)
     Algolia.client.get(Protocol.browse_uri(name, {:page => page, :hitsPerPage => hitsPerPage}))
    end

    #
    # Get an object from this index
    # 
    # @param objectID the unique identifier of the object to retrieve
    # @param attributesToRetrieve (optional) if set, contains the list of attributes to retrieve as a string separated by ","
    #
    def get_object(objectID, attributesToRetrieve = nil)
      if attributesToRetrieve.nil?
        Algolia.client.get(Protocol.object_uri(name, objectID, nil))
      else
        Algolia.client.get(Protocol.object_uri(name, objectID, {:attributes => attributesToRetrieve}))
      end
    end

    #
    # Get a list of objects from this index
    #
    # @param objectIDs the array of unique identifier of the objects to retrieve
    #
    def get_objects(objectIDs)
      Algolia.client.post(Protocol.objects_uri, { :requests => objectIDs.map { |objectID| { :indexName => name, :objectID => objectID } } }.to_json)['results']
    end

    # Wait the publication of a task on the server. 
    # All server task are asynchronous and you can check with this method that the task is published.
    #
    # @param taskID the id of the task returned by server
    # @param timeBeforeRetry the time in milliseconds before retry (default = 100ms)
    #    
    def wait_task(taskID, timeBeforeRetry = 100)
      loop do
        status = Algolia.client.get(Protocol.task_uri(name, taskID))["status"]
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
      Algolia.client.put(Protocol.object_uri(name, get_objectID(obj, objectID)), obj.to_json)
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
      Algolia.client.post(Protocol.partial_object_uri(name, get_objectID(obj, objectID), create_if_not_exits), obj.to_json)
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
      Algolia.client.delete(Protocol.object_uri(name, objectID))
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
    def delete_by_query(query, params = {})
      params.delete(:hitsPerPage)
      params.delete('hitsPerPage')
      params.delete(:attributesToRetrieve)
      params.delete('attributesToRetrieve')

      params[:hitsPerPage] = 1000
      params[:attributesToRetrieve] = ['objectID']
      loop do
        res = search(query, params)
        break if res['hits'].empty?
        res = delete_objects(res['hits'].map { |h| h['objectID'] })
        wait_task res['taskID']
      end
    end

    #
    # Delete the index content
    # 
    #
    def clear
      Algolia.client.post(Protocol.clear_uri(name))
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
    # @param settigns the settings object that can contains :
    # - minWordSizefor1Typo: (integer) the minimum number of characters to accept one typo (default = 3).
    # - minWordSizefor2Typos: (integer) the minimum number of characters to accept two typos (default = 7).
    # - hitsPerPage: (integer) the number of hits per page (default = 10).
    # - attributesToRetrieve: (array of strings) default list of attributes to retrieve in objects. 
    #   If set to null, all attributes are retrieved.
    # - attributesToHighlight: (array of strings) default list of attributes to highlight. 
    #   If set to null, all indexed attributes are highlighted.
    # - attributesToSnippet**: (array of strings) default list of attributes to snippet alongside the number of words to return (syntax is attributeName:nbWords).
    #   By default no snippet is computed. If set to null, no snippet is computed.
    # - attributesToIndex: (array of strings) the list of fields you want to index.
    #   If set to null, all textual and numerical attributes of your objects are indexed, but you should update it to get optimal results.
    #   This parameter has two important uses:
    #     - Limit the attributes to index: For example if you store a binary image in base64, you want to store it and be able to 
    #       retrieve it but you don't want to search in the base64 string.
    #     - Control part of the ranking*: (see the ranking parameter for full explanation) Matches in attributes at the beginning of 
    #       the list will be considered more important than matches in attributes further down the list. 
    #       In one attribute, matching text at the beginning of the attribute will be considered more important than text after, you can disable 
    #       this behavior if you add your attribute inside `unordered(AttributeName)`, for example attributesToIndex: ["title", "unordered(text)"].
    # - attributesForFaceting: (array of strings) The list of fields you want to use for faceting. 
    #   All strings in the attribute selected for faceting are extracted and added as a facet. If set to null, no attribute is used for faceting.
    # - attributeForDistinct: (string) The attribute name used for the Distinct feature. This feature is similar to the SQL "distinct" keyword: when enabled 
    #   in query with the distinct=1 parameter, all hits containing a duplicate value for this attribute are removed from results. 
    #   For example, if the chosen attribute is show_name and several hits have the same value for show_name, then only the best one is kept and others are removed.
    # - ranking: (array of strings) controls the way results are sorted.
    #   We have six available criteria: 
    #    - typo: sort according to number of typos,
    #    - geo: sort according to decreassing distance when performing a geo-location based search,
    #    - proximity: sort according to the proximity of query words in hits,
    #    - attribute: sort according to the order of attributes defined by attributesToIndex,
    #    - exact: 
    #        - if the user query contains one word: sort objects having an attribute that is exactly the query word before others. 
    #          For example if you search for the "V" TV show, you want to find it with the "V" query and avoid to have all popular TV 
    #          show starting by the v letter before it.
    #        - if the user query contains multiple words: sort according to the number of words that matched exactly (and not as a prefix).
    #    - custom: sort according to a user defined formula set in **customRanking** attribute.
    #   The standard order is ["typo", "geo", "proximity", "attribute", "exact", "custom"]
    # - customRanking: (array of strings) lets you specify part of the ranking.
    #   The syntax of this condition is an array of strings containing attributes prefixed by asc (ascending order) or desc (descending order) operator.
    #   For example `"customRanking" => ["desc(population)", "asc(name)"]`  
    # - queryType: Select how the query words are interpreted, it can be one of the following value:
    #   - prefixAll: all query words are interpreted as prefixes,
    #   - prefixLast: only the last word is interpreted as a prefix (default behavior),
    #   - prefixNone: no query word is interpreted as a prefix. This option is not recommended.
    # - highlightPreTag: (string) Specify the string that is inserted before the highlighted parts in the query result (default to "<em>").
    # - highlightPostTag: (string) Specify the string that is inserted after the highlighted parts in the query result (default to "</em>").
    # - optionalWords: (array of strings) Specify a list of words that should be considered as optional when found in the query.
    #
    def set_settings(new_settings)
      Algolia.client.put(Protocol.settings_uri(name), new_settings.to_json)
    end
    
    # Get settings of this index
    def get_settings
      Algolia.client.get(Protocol.settings_uri(name))
    end 

    # List all existing user keys with their associated ACLs
    def list_user_keys
      Algolia.client.get(Protocol.index_keys_uri(name))
    end
 
    # Get ACL of a user key
    def get_user_key(key)
      Algolia.client.get(Protocol.index_key_uri(name, key))
    end
 
    #
    #  Create a new user key
    #
    #  @param acls the list of ACL for this key. Defined by an array of strings that 
    #         can contains the following values:
    #           - search: allow to search (https and http)
    #           - addObject: allows to add a new object in the index (https only)
    #           - updateObject : allows to change content of an existing object (https only)
    #           - deleteObject : allows to delete an existing object (https only)
    #           - deleteIndex : allows to delete index content (https only)
    #           - settings : allows to get index settings (https only)
    #           - editSettings : allows to change index settings (https only)
    #  @param validity the number of seconds after which the key will be automatically removed (0 means no time limit for this key)
    #
    def add_user_key(acls, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0)
      Algolia.client.post(Protocol.index_keys_uri(name), {:acl => acls, :validity => validity, :maxQueriesPerIPPerHour => maxQueriesPerIPPerHour.to_i, :maxHitsPerQuery => maxHitsPerQuery.to_i}.to_json)
    end
 
    # Delete an existing user key
    def delete_user_key(key)
      Algolia.client.delete(Protocol.index_key_uri(name, key))
    end

    # Send a batch request
    def batch(request)
      Algolia.client.post(Protocol.batch_uri(name), request.to_json)
    end

    # Send a batch request and wait the end of the indexing
    def batch!(request)
      res = batch(request)
      wait_task(res['taskID'])
      res
    end

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
          :facetFilters => filters
        })
      end
      answers = Algolia.multiple_queries(queries)

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

  end
end
