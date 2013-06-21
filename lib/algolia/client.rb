require 'algolia/protocol'
require 'algolia/error'
require 'json'

module Algolia

  # A class which encapsulates the HTTPS communication with the Algolia
  # API server. Uses the Curb (Curl) library for low-level HTTP communication.
  class Client
    attr_accessor :hosts
    attr_accessor :ssl
    attr_accessor :application_id
    attr_accessor :api_key

    def initialize(data = {})
      @ssl            = data[:ssl].nil? ? true : data[:ssl]
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @gzip           = data[:gzip].nil? ? false : data[:gzip]

      rhosts = data[:hosts].shuffle
      @hosts = []
      rhosts.each do |host|
        hinfo = {}
        hinfo["base_url"] = "http#{@ssl ? 's' : ''}://#{host}"
        hinfo["host"] = host
        hinfo["session"] = Curl::Easy.new(@base_url) do |s|
          s.headers[Protocol::HEADER_API_KEY]  = @api_key
          s.headers[Protocol::HEADER_APP_ID]   = @application_id
          s.headers["Content-Type"]            = "application/json; charset=utf-8"
          s.headers["Accept"]                  = "Accept-Encoding: gzip,deflate" if @gzip
          s.headers["User-Agent"]              = "Algolia for Ruby"
          s.verbose                            = true if data[:debug]
        end
        @hosts.push(hinfo)
      end
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # AlgoliaProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method, data = nil)
      @hosts.each do |host|
        begin
          session = host["session"]
          session.url = host["base_url"] + uri
          case method
          when :GET
            session.http_get
          when :POST
            session.post_body = data
            session.http_post
          when :PUT
            session.http_put(data)
          when :DELETE
            session.http_delete
          end
          if session.response_code >= 400 || session.response_code < 200
            raise AlgoliaProtocolError.new(session.response_code, "#{method} #{session.url}: #{session.body_str}")
          end
          return JSON.parse(session.body_str)          
        rescue AlgoliaProtocolError => e
          if e.code != Protocol::ERROR_TIMEOUT and e.code != Protocol::ERROR_UNAVAILABLE 
            raise
          end
        rescue Curl::Err::CurlError => e
        end
      end
      raise AlgoliaProtocolError.new(0, "Cannot reach any hosts")
    end

    def get(uri)
      request(uri, :GET)
    end

    def post(uri, body)
      request(uri, :POST, body)
    end

    def put(uri, body)
      request(uri, :PUT, body)
    end

    def delete(uri)
      request(uri, :DELETE)
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
    defaulted = { :api_id => ENV["ALGOLIA_API_ID"], :api_key => ENV["ALGOLIA_REST_API_KEY"] }
    defaulted.merge!(options)

    @@client = Client.new(defaulted)
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
  #
  def Algolia.add_user_key(acls)
      Algolia.client.post(Protocol.keys_uri, {"acl" => acls}.to_json)
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