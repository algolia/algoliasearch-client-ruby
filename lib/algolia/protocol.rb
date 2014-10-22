require 'cgi'

module Algolia
  # A module which encapsulates the specifics of Algolia's REST API.
  module Protocol

    # Basics
 
    # The version of the REST API implemented by this module.
    VERSION         = 1

    # HTTP Headers
    # ----------------------------------------

    # The HTTP header used for passing your application ID to the
    # Algolia API.
    HEADER_APP_ID   = "X-Algolia-Application-Id"

    # The HTTP header used for passing your API key to the
    # Algolia API.
    HEADER_API_KEY  = "X-Algolia-API-Key"
    
    HEADER_FORWARDED_IP = "X-Forwarded-For"

    HEADER_FORWARDED_API_KEY = "X-Forwarded-API-Key"
    
    # HTTP ERROR CODES
    # ----------------------------------------

    ERROR_BAD_REQUEST = 400
    ERROR_FORBIDDEN = 403
    ERROR_NOT_FOUND = 404

    # URI Helpers
    # ----------------------------------------

    # Construct a uri to list available indexes
    def Protocol.indexes_uri      
      "/#{VERSION}/indexes"
    end

    def Protocol.multiple_queries_uri
      "/#{VERSION}/indexes/*/queries"
    end

    def Protocol.objects_uri
      "/#{VERSION}/indexes/*/objects"
    end

    # Construct a uri referencing a given Algolia index
    def Protocol.index_uri(index)
      "/#{VERSION}/indexes/#{CGI.escape(index)}"
    end

    def Protocol.batch_uri(index)
      "#{index_uri(index)}/batch"
    end
    
    def Protocol.index_operation_uri(index)
      "#{index_uri(index)}/operation"
    end

    def Protocol.task_uri(index, task_id)
      "#{index_uri(index)}/task/#{task_id}"
    end
    
    def Protocol.object_uri(index, object_id, params = {})
      params = params.nil? || params.size == 0 ? "" : "?#{to_query(params)}"
      "#{index_uri(index)}/#{CGI.escape(object_id.to_s)}#{params}"
    end

    def Protocol.search_uri(index, query, params = {})
      params = params.nil? || params.size == 0 ? "" : "&#{to_query(params)}"
      "#{index_uri(index)}?query=#{CGI.escape(query)}&#{params}"
    end

    def Protocol.browse_uri(index, params = {})
      params = params.nil? || params.size == 0 ? "" : "?#{to_query(params)}"
      "#{index_uri(index)}/browse#{params}"
    end

    def Protocol.partial_object_uri(index, object_id)
      "#{index_uri(index)}/#{CGI.escape(object_id)}/partial"
    end
    
    def Protocol.settings_uri(index)
      "#{index_uri(index)}/settings"
    end
    
    def Protocol.clear_uri(index)
      "#{index_uri(index)}/clear"
    end
    
    def Protocol.logs(offset, length, only_errors = false)
      "/#{VERSION}/logs?offset=#{offset}&length=#{length}&onlyErrors=#{only_errors}"
    end

    def Protocol.keys_uri
      "/#{VERSION}/keys"
    end

    def Protocol.key_uri(key)
      "/#{VERSION}/keys/#{key}"
    end

    def Protocol.index_key_uri(index, key)
      "#{index_uri(index)}/keys/#{key}"
    end

    def Protocol.index_keys_uri(index)
      "#{index_uri(index)}/keys"
    end

    def Protocol.to_query(params)
      params.map do |k, v|
        "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}"
      end.join('&')
    end
    
  end
end
