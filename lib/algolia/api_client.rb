require 'date'
require 'json'
require 'logger'
require 'tempfile'
require 'time'
require 'faraday'

module Algolia
  class ApiClient
    # The Configuration object holding settings to be used in the API client.
    attr_accessor :config

    # Defines the headers to be used in HTTP requests of all API calls by default.
    #
    # @return [Hash]
    attr_accessor :default_headers

    # Initializes the ApiClient
    # @option config [Configuration] Configuration for initializing the object, default to Configuration.default
    def initialize(config = Configuration.default)
      @config = config
      @user_agent = "Algolia for Ruby (#{VERSION}); Ruby (#{RUBY_VERSION})"
      @default_headers = {
        'X-Algolia-Application-Id' => config.app_id,
        'X-Algolia-API-Key' => config.api_key,
        'Content-Type' => 'application/json',
        'User-Agent' => @user_agent
      }
    end

    def self.default
      @@default ||= ApiClient.new
    end

    # Call an API with given options.
    #
    # @return [Array<(Object, Integer, Hash)>] an array of 3 elements:
    #   the data deserialized from response body (could be nil), response status code and response headers.
    def call_api(http_method, path, opts = {})
      begin
        response = build_connection().public_send(http_method.to_sym.downcase) do |req|
          build_request(http_method, path, req, opts)
        end

        if config.debugging
          config.logger.debug "HTTP response body ~BEGIN~\n#{response.body}\n~END~\n"
        end

        unless response.success?
          if response.status == 0 && response.respond_to?(:return_message)
            # Errors from libcurl will be made visible here
            fail ApiError.new(code: 0,
                              message: response.return_message)
          else
            fail ApiError.new(code: response.status,
                              response_headers: response.headers,
                              response_body: response.body),
                 response.reason_phrase
          end
        end
      rescue Faraday::TimeoutError
        fail ApiError.new('Connection timed out')
      rescue Faraday::ConnectionFailed
        fail ApiError.new('Connection failed')
      end

      if opts[:return_type]
        data = deserialize(response, opts[:return_type])
      else
        data = nil
      end
      return data, response.status, response.headers
    end

    # Builds the HTTP request
    #
    # @param [String] http_method HTTP method/verb (e.g. POST)
    # @param [String] path URL path (e.g. /account/new)
    # @option opts [Hash] :header_params Header parameters
    # @option opts [Hash] :query_params Query parameters
    # @option opts [Object] :body HTTP body (JSON/XML)
    # @return [Faraday::Request] A Faraday Request
    def build_request(http_method, path, request, opts = {})
      url = build_request_url(path, opts)
      http_method = http_method.to_sym.downcase

      header_params = @default_headers.merge(opts[:header_params] || {})
      query_params = opts[:query_params] || {}

      if [:post, :patch, :put, :delete].include?(http_method)
        req_body = build_request_body(opts[:body])
        if config.debugging
          config.logger.debug "URL: #{url}"
          config.logger.debug "HTTP request body param ~BEGIN~\n#{req_body}\n~END~\n"
        end
      end
      request.headers = header_params
      request.body = req_body

      # Overload default options only if provided
      request.options.params_encoder = config.params_encoder if config.params_encoder
      request.options.timeout        = config.timeout        if config.timeout

      request.url url
      request.params = query_params
      request
    end

    # Builds the HTTP request body
    #
    # @param [Object] body HTTP body (JSON)
    # @return [String] HTTP body data in the form of string
    def build_request_body(body)
      if body
        data = body.is_a?(String) ? body : body.to_json
      else
        data = nil
      end
      data
    end

    def build_connection
      Faraday.new(url: 'https://' + config.hosts[0].url, ssl: ssl_options, proxy: config.proxy) do |conn|
        config.configure_middleware(conn)
        yield(conn) if block_given?
        conn.adapter(Faraday.default_adapter)
        config.configure_connection(conn)
      end
    end

    def ssl_options
      {
        ca_file: config.ssl_ca_file,
        verify: config.ssl_verify,
        verify_mode: config.ssl_verify_mode,
        client_cert: config.ssl_client_cert,
        client_key: config.ssl_client_key
      }
    end

    # Deserialize the response to the given return type.
    #
    # @param [Response] response HTTP response
    # @param [String] return_type some examples: "User", "Array<User>", "Hash<String, Integer>"
    def deserialize(response, return_type)
      body = response.body
      return nil if body.nil? || body.empty?

      # return response body directly for String return type
      return body.to_s if return_type == 'String'

      begin
        data = JSON.parse("[#{body}]", :symbolize_names => true)[0]
      rescue JSON::ParserError => e
        if %w(String Date Time).include?(return_type)
          data = body
        else
          raise e
        end
      end

      convert_to_type data, return_type
    end

    # Convert data to the given return type.
    # @param [Object] data Data to be converted
    # @param [String] return_type Return type
    # @return [Mixed] Data in a particular type
    def convert_to_type(data, return_type)
      return nil if data.nil?
      case return_type
      when 'String'
        data.to_s
      when 'Integer'
        data.to_i
      when 'Float'
        data.to_f
      when 'Boolean'
        data == true
      when 'Time'
        # parse date time (expecting ISO 8601 format)
        Time.parse data
      when 'Date'
        # parse date time (expecting ISO 8601 format)
        Date.parse data
      when 'Object'
        # generic object (usually a Hash), return directly
        data
      when /\AArray<(.+)>\z/
        # e.g. Array<Pet>
        sub_type = $1
        data.map { |item| convert_to_type(item, sub_type) }
      when /\AHash\<String, (.+)\>\z/
        # e.g. Hash<String, Integer>
        sub_type = $1
        {}.tap do |hash|
          data.each { |k, v| hash[k] = convert_to_type(v, sub_type) }
        end
      else
        # models (e.g. Pet) or oneOf
        klass = Algolia.const_get(return_type)
        klass.respond_to?(:openapi_one_of) ? klass.build(data) : klass.build_from_hash(data)
      end
    end

    def build_request_url(path, opts = {})
      # Add leading and trailing slashes to path
      path = "/#{path}".gsub(/\/+/, '/')
      'https://' + @config.hosts[0].url + path
    end

    # Sets user agent in HTTP header
    #
    # @param [String] user_agent User agent (e.g. openapi-generator/ruby/1.0.0)
    def user_agent=(user_agent)
      @user_agent = user_agent
      @default_headers['User-Agent'] = @user_agent
    end

    # Convert object (array, hash, object, etc) to JSON string.
    # @param [Object] model object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_http_body(model)
      return model if model.nil? || model.is_a?(String)
      local_body = nil
      if model.is_a?(Array)
        local_body = model.map { |m| object_to_hash(m) }
      else
        local_body = object_to_hash(model)
      end
      local_body.to_json
    end

    # Convert object(non-array) to hash.
    # @param [Object] obj object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_hash(obj)
      if obj.respond_to?(:to_hash)
        obj.to_hash
      else
        obj
      end
    end

    # Build parameter value according to the given collection format.
    # @param [String] collection_format one of :csv, :ssv, :tsv, :pipes and :multi
    def build_collection_param(param, collection_format)
      case collection_format
      when :csv
        param.join(',')
      when :ssv
        param.join(' ')
      when :tsv
        param.join("\t")
      when :pipes
        param.join('|')
      when :multi
        # return the array directly as typhoeus will handle it as expected
        param
      else
        fail "unknown collection format: #{collection_format.inspect}"
      end
    end
  end
end
