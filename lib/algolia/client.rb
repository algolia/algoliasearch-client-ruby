require 'algolia/protocol'
require 'algolia/error'
require 'algolia/version'
require 'json'
require 'zlib'

module Algolia

  # A class which encapsulates the HTTPS communication with the Algolia
  # API server. Uses the HTTPClient library for low-level HTTP communication.
  class Client
    attr_reader :hosts, :application_id, :api_key, :headers


    def initialize(data = {})
      @ssl            = data[:ssl].nil? ? true : data[:ssl]
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @hosts          = (data[:hosts] || 1.upto(3).map { |i| "#{@application_id}-#{i}.algolia.io" }).shuffle
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
    def request(uri, method, data = nil)
      exceptions = []
      thread_local_hosts.each do |host|
        begin
          return perform_request(host[:session], host[:base_url] + uri, method, data)
        rescue AlgoliaProtocolError => e
          raise if e.code != Protocol::ERROR_TIMEOUT and e.code != Protocol::ERROR_UNAVAILABLE
          exceptions << e
        rescue HTTPClient::BadResponseError, OpenSSL::SSL::SSLError => e
          exceptions << e
        end
      end
      raise AlgoliaProtocolError.new(0, "Cannot reach any host: #{exceptions.map { |e| e.to_s }.join(', ')}")
    end

    def get(uri)
      request(uri, :GET)
    end

    def post(uri, body = {})
      request(uri, :POST, body)
    end

    def put(uri, body = {})
      request(uri, :PUT, body)
    end

    def delete(uri)
      request(uri, :DELETE)
    end

    private

    # this method returns a thread-local array of sessions
    def thread_local_hosts
      Thread.current[:algolia_hosts] ||= hosts.map do |host|
        hinfo = {
          :base_url => "http#{@ssl ? 's' : ''}://#{host}",
          :session => HTTPClient.new
        }
        hinfo[:session].transparent_gzip_decompression = true
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
      if response.code >= 400 || response.code < 200
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

    @@client = Client.new(defaulted)
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
  # List all existing indexes
  # return an Answer object with answer in the form 
  #     {"items": [{ "name": "contacts", "createdAt": "2013-01-18T15:33:13.556Z"},
  #                {"name": "notes", "createdAt": "2013-01-18T15:33:13.556Z"}]}
  #
  def Algolia.list_indexes
      Algolia.client.get(Protocol.indexes_uri)
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
  # Copy an existing index.
  # @param src_index the name of index to copy.
  # @param dst_index the new index name that will contains a copy of srcIndexName (destination will be overriten if it already exist).
  #
  def Algolia.copy_index(src_index, dst_index)
      request = {"operation" => "copy", "destination" => dst_index};
      Algolia.client.post(Protocol.index_operation_uri(src_index), request.to_json)
  end

  #
  # Return last logs entries.
  #
  # @param offset Specify the first entry to retrieve (0-based, 0 is the most recent log entry).
  # @param length Specify the maximum number of entries to retrieve starting at offset. Maximum allowed value: 1000.
  #
  def Algolia.get_logs(offset = 0, length = 10)
      Algolia.client.get(Protocol.logs(offset, length))
  end

  # List all existing user keys with their associated ACLs
  def Algolia.list_user_keys
      Algolia.client.get(Protocol.keys_uri)
  end

  # Get ACL of a user key
  def Algolia.get_user_key(key)
      Algolia.client.get(Protocol.key_uri(key))
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
  #  @param maxQueriesPerIPPerHour the maximum number of API calls allowed from an IP address per hour (0 means unlimited)
  #  @param maxHitsPerQuery  the maximum number of hits this API key can retrieve in one call (0 means unlimited)
  #  @param indexes the optional list of targeted indexes
  #
  def Algolia.add_user_key(acls, validity = 0, maxQueriesPerIPPerHour = 0, maxHitsPerQuery = 0, indexes = nil)
    params = {
      :acl => acls,
      :validity => validity.to_i,
      :maxQueriesPerIPPerHour => maxQueriesPerIPPerHour.to_i,
      :maxHitsPerQuery => maxHitsPerQuery.to_i
    }
    params[:indexes] = indexes if indexes
    Algolia.client.post(Protocol.keys_uri, params.to_json)
  end

  # Delete an existing user key
  def Algolia.delete_user_key(key)
      Algolia.client.delete(Protocol.key_uri(key))
  end

  # Used mostly for testing. Lets you delete the api key global vars.
  def Algolia.destroy
    @@client = nil
    self
  end

  def Algolia.client
    if !@@client
      raise AlgoliaError, "API not initialized"
    end
    @@client
  end

end
