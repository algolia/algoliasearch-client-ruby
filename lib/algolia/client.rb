require 'algolia/protocol'
require 'algolia/error'
require 'algolia/version'
require 'json'
require 'zlib'
require 'openssl'

module Algolia

  # A class which encapsulates the HTTPS communication with the Algolia
  # API server. Uses the HTTPClient library for low-level HTTP communication.
  class Client
    attr_reader :ssl, :ssl_version, :hosts, :search_hosts, :application_id, :api_key, :headers, :connect_timeout, :send_timeout, :receive_timeout, :search_timeout, :batch_timeout

    DEFAULT_CONNECT_TIMEOUT = 2
    DEFAULT_RECEIVE_TIMEOUT = 30
    DEFAULT_SEND_TIMEOUT    = 30
    DEFAULT_BATCH_TIMEOUT   = 120
    DEFAULT_SEARCH_TIMEOUT  = 5

    def initialize(data = {})
      @ssl             = data[:ssl].nil? ? true : data[:ssl]
      @ssl_version     = data[:ssl_version].nil? ? nil : data[:ssl_version]
      @application_id  = data[:application_id]
      @api_key         = data[:api_key]
      @hosts           = data[:hosts] || (["#{@application_id}.algolia.net"] + 1.upto(3).map { |i| "#{@application_id}-#{i}.algolianet.com" }.shuffle)
      @search_hosts    = data[:search_hosts] || data[:hosts] || (["#{@application_id}-dsn.algolia.net"] + 1.upto(3).map { |i| "#{@application_id}-#{i}.algolianet.com" }.shuffle)
      @connect_timeout = data[:connect_timeout] || DEFAULT_CONNECT_TIMEOUT
      @send_timeout    = data[:send_timeout] || DEFAULT_SEND_TIMEOUT
      @batch_timeout   = data[:batch_timeout] || DEFAULT_BATCH_TIMEOUT
      @receive_timeout = data[:receive_timeout] || DEFAULT_RECEIVE_TIMEOUT
      @search_timeout  = data[:search_timeout] || DEFAULT_SEARCH_TIMEOUT
      @headers = {
        Protocol::HEADER_API_KEY => api_key,
        Protocol::HEADER_APP_ID  => application_id,
        'Content-Type'           => 'application/json; charset=utf-8',
        'User-Agent'             => "Algolia for Ruby #{::Algolia::VERSION}"
      }
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # AlgoliaProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method, data = nil, type = :write)
      exceptions = []

      connect_timeout = @connect_timeout
      send_timeout = if type == :search
        @search_timeout
      elsif type == :batch
        type = :write
        @batch_timeout
      else
        @send_timeout
      end
      receive_timeout = type == :search ? @search_timeout : @receive_timeout

      (type == :write ? @hosts : @search_hosts).size.times do |i|
        connect_timeout += 2 if i == 2
        send_timeout += 10 if i == 2
        receive_timeout += 10 if i == 2

        host = thread_local_hosts(type != :write, connect_timeout, send_timeout, receive_timeout)[i]
        begin
          return perform_request(host[:session], host[:base_url] + uri, method, data)
        rescue AlgoliaProtocolError => e
          raise if e.code / 100 == 4
          exceptions << e
        rescue => e
          exceptions << e
        end
      end
      raise AlgoliaProtocolError.new(0, "Cannot reach any host: #{exceptions.map { |e| e.to_s }.join(', ')}")
    end

    def get(uri, type = :write)
      request(uri, :GET, nil, type)
    end

    def post(uri, body = {}, type = :write)
      request(uri, :POST, body, type)
    end

    def put(uri, body = {}, type = :write)
      request(uri, :PUT, body, type)
    end

    def delete(uri, type = :write)
      request(uri, :DELETE, nil, type)
    end

    private

    # This method returns a thread-local array of sessions
    #
    # Since the underlying httpclient library resets the connections pool
    # if you change any of its attributes, we cannot change the timeout
    # of an HTTP session dynamically. That being said, having 1 pool per
    # timeout appears to be the only acceptable solution
    def thread_local_hosts(read, connect_timeout, send_timeout, receive_timeout)
      thread_local_var = read ? :algolia_search_hosts : :algolia_hosts
      Thread.current[thread_local_var] ||= {}
      Thread.current[thread_local_var]["#{connect_timeout}-#{send_timeout}-#{receive_timeout}"] ||= (read ? search_hosts : hosts).map do |host|
        client = HTTPClient.new
        client.ssl_config.ssl_version = @ssl_version if @ssl && @ssl_version
        hinfo = {
          :base_url => "http#{@ssl ? 's' : ''}://#{host}",
          :session => client
        }
        hinfo[:session].transparent_gzip_decompression = true
        hinfo[:session].connect_timeout = connect_timeout
        hinfo[:session].send_timeout = send_timeout
        hinfo[:session].receive_timeout = receive_timeout
        hinfo[:session].ssl_config.add_trust_ca File.join(File.dirname(__FILE__), '..', '..', 'resources', 'ca-bundle.crt')
        hinfo
      end
    end

    private
    def perform_request(session, url, method, data)
      response = case method
      when :GET
        session.get(url, { :header => @headers })
      when :POST
        session.post(url, { :body => data, :header => @headers })
      when :PUT
        session.put(url, { :body => data, :header => @headers })
      when :DELETE
        session.delete(url, { :header => @headers })
      end
      if response.code / 100 != 2
        raise AlgoliaProtocolError.new(response.code, "Cannot #{method} to #{url}: #{response.content} (#{response.code})")
      end
      return JSON.parse(response.content)
    end

  end

  # Module methods
  # ------------------------------------------------------------

  # A singleton client
  # Always use Algolia.client to retrieve the client object.
  @@client = nil

  # Initialize the singleton instance of Client which is used
  # by all API methods.
  def Algolia.init(options = {})
    application_id = ENV["ALGOLIA_API_ID"] || ENV["ALGOLIA_APPLICATION_ID"]
    api_key = ENV["ALGOLIA_REST_API_KEY"] || ENV['ALGOLIA_API_KEY']

    defaulted = { :application_id => application_id, :api_key => api_key }
    defaulted.merge!(options)

    raise ArgumentError.new("No APPLICATION_ID provided, please set :application_id") if defaulted[:application_id].nil?

    @@client = Client.new(defaulted)
  end

  #
  # Allow to set custom headers
  #
  def Algolia.set_extra_header(key, value)
    Algolia.client.headers[key] = value
  end

  #
  # Allow to use IP rate limit when you have a proxy between end-user and Algolia.
  # This option will set the X-Forwarded-For HTTP header with the client IP and the X-Forwarded-API-Key with the API Key having rate limits.
  # @param admin_api_key the admin API Key you can find in your dashboard
  # @param end_user_ip the end user IP (you can use both IPV4 or IPV6 syntax)
  # @param rate_limit_api_key the API key on which you have a rate limit
  #
  def Algolia.enable_rate_limit_forward(admin_api_key, end_user_ip, rate_limit_api_key)
    Algolia.client.headers[Protocol::HEADER_API_KEY] = admin_api_key
    Algolia.client.headers[Protocol::HEADER_FORWARDED_IP] = end_user_ip
    Algolia.client.headers[Protocol::HEADER_FORWARDED_API_KEY] = rate_limit_api_key
  end

  #
  # Disable IP rate limit enabled with enableRateLimitForward() function
  #
  def Algolia.disable_rate_limit_forward
    Algolia.client.headers[Protocol::HEADER_API_KEY] = Algolia.client.api_key
    Algolia.client.headers.delete(Protocol::HEADER_FORWARDED_IP)
    Algolia.client.headers.delete(Protocol::HEADER_FORWARDED_API_KEY)
  end

  #
  # Convenience method thats wraps enable_rate_limit_forward/disable_rate_limit_forward
  #
  def Algolia.with_rate_limits(end_user_ip, rate_limit_api_key, &block)
    Algolia.enable_rate_limit_forward(Algolia.client.api_key, end_user_ip, rate_limit_api_key)
    begin
      yield
    ensure
      Algolia.disable_rate_limit_forward
    end
  end

  #
  # Generate a secured and public API Key from a list of tagFilters and an
  # optional user token identifying the current user
  #
  # @param private_api_key your private API Key
  # @param tag_filters the list of tags applied to the query (used as security)
  # @param user_token an optional token identifying the current user
  #
  def Algolia.generate_secured_api_key(private_api_key, tag_filters, user_token = nil)
    if tag_filters.is_a?(Array)
      tag_filters = tag_filters.map { |t| t.is_a?(Array) ? "(#{t.join(',')})" : t }.join(',')
    end
    raise ArgumentError.new('Attribute "tag_filters" must be a list of tags') if !tag_filters.is_a?(String)
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), private_api_key, "#{tag_filters}#{user_token.to_s}")
  end

  #
  # This method allows to query multiple indexes with one API call
  # 
  # @param queries the array of hash representing the query and associated index name
  # @param index_name_key the name of the key used to fetch the index_name (:index_name by default)
  # @param strategy define the strategy applied on the sequential searches (none by default)
  #
  def Algolia.multiple_queries(queries, index_name_key = :index_name, strategy = "none")
    requests = {
      :requests => queries.map do |query|
        indexName = query.delete(index_name_key) || query.delete(index_name_key.to_s)
        encoded_params = Hash[query.map { |k,v| [k.to_s, v.is_a?(Array) ? v.to_json : v] }]
        { :indexName => indexName, :params => Protocol.to_query(encoded_params) }
      end
    }
    Algolia.client.post(Protocol.multiple_queries_uri(strategy), requests.to_json, :search)
  end

  #
  # List all existing indexes
  # return an Answer object with answer in the form 
  #     {"items": [{ "name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"},
  #                {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
  #
  def Algolia.list_indexes
      Algolia.client.get(Protocol.indexes_uri, :read)
  end

  #
  # Move an existing index.
  # @param src_index the name of index to copy.
  # @param dst_index the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
  #
  def Algolia.move_index(src_index, dst_index)
      request = {"operation" => "move", "destination" => dst_index};
      Algolia.client.post(Protocol.index_operation_uri(src_index), request.to_json)
  end

  #
  # Move an existing index and wait until the move has been processed
  # @param src_index the name of index to copy.
  # @param dst_index the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
  #
  def Algolia.move_index!(src_index, dst_index)
      res = Algolia.move_index(src_index, dst_index)
      Index.new(dst_index).wait_task(res['taskID'])
      res
  end

  #
  # Copy an existing index.
  # @param src_index the name of index to copy.
  # @param dst_index the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
  #
  def Algolia.copy_index(src_index, dst_index)
      request = {"operation" => "copy", "destination" => dst_index};
      Algolia.client.post(Protocol.index_operation_uri(src_index), request.to_json)
  end

  #
  # Copy an existing index and wait until the copy has been processed.
  # @param src_index the name of index to copy.
  # @param dst_index the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
  #
  def Algolia.copy_index!(src_index, dst_index)
      res = Algolia.copy_index(src_index, dst_index)
      Index.new(dst_index).wait_task(res['taskID'])
      res
  end

  # Delete an index
  #
  def delete_index(name)
    Index.new(name).delete
  end

  # Delete an index and wait until the deletion has been processed.
  #
  def delete_index!(name)
    Index.new(name).delete!
  end

  #
  # Return last logs entries.
  #
  # @param offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
  # @param length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
  #
  def Algolia.get_logs(offset = 0, length = 10, type = "all")
      if (type.is_a?(true.class))
        if (type)
          type = "error"
        else
          type = "all"
        end
      end
      Algolia.client.get(Protocol.logs(offset, length, type))
  end

  # List all existing user keys with their associated ACLs
  def Algolia.list_user_keys
      Algolia.client.get(Protocol.keys_uri, :read)
  end

  # Get ACL of a user key
  def Algolia.get_user_key(key)
      Algolia.client.get(Protocol.key_uri(key), :read)
  end

  #
  #  Create a new user key
  #
  #  @param obj can be two different parameters:
  #        The list of parameters for this key. Defined by a NSDictionary that
  #        can contains the following values:
  #          - acl: array of string
  #          - indices: array of string
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
  #  @param indexes the optional list of targeted indexes
  #
  def Algolia.add_user_key(obj, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0, indexes = nil)
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
    params[:indexes] = indexes if indexes
    Algolia.client.post(Protocol.keys_uri, params.to_json)
  end

  #
  #  Update a user key
  #
  #  @param obj can be two different parameters:
  #        The list of parameters for this key. Defined by a NSDictionary that
  #        can contains the following values:
  #          - acl: array of string
  #          - indices: array of string
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
  #  @param indexes the optional list of targeted indexes
  #
  def Algolia.update_user_key(key, obj, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0, indexes = nil)
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
    params[:indexes] = indexes if indexes
    Algolia.client.put(Protocol.key_uri(key), params.to_json)
  end


  # Delete an existing user key
  def Algolia.delete_user_key(key)
      Algolia.client.delete(Protocol.key_uri(key))
  end

  # Send a batch request targeting multiple indices
  def Algolia.batch(requests)
    Algolia.client.post(Protocol.batch_uri, {"requests" => requests}.to_json, :batch)
  end

  # Send a batch request targeting multiple indices and wait the end of the indexing
  def Algolia.batch!(requests)
    res = batch(requests)
    res['taskID'].each { |index, taskID|
      Algolia::Index.new(index).wait_task(taskID)
    }
  end

  # Used mostly for testing. Lets you delete the api key global vars.
  def Algolia.destroy
    @@client = Thread.current[:algolia_hosts] = Thread.current[:algolia_search_hosts] = nil
    self
  end

  def Algolia.client
    if !@@client
      raise AlgoliaError, "API not initialized"
    end
    @@client
  end

end
