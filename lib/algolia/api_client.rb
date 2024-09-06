require "cgi"
require "json"

module Algolia
  class ApiClient
    # The Configuration object holding settings to be used in the API client.
    attr_accessor :config

    attr_accessor :transporter

    # Initializes the ApiClient
    # @option config [Configuration] Configuration for initializing the object, default to Configuration.default
    def initialize(config = Configuration.default)
      @config = config
      @requester = config.requester || Http::HttpRequester.new("net_http_persistent", LoggerHelper.create)
      @transporter = Transport::Transport.new(config, @requester)
    end

    def self.default
      @@default ||= ApiClient.new
    end

    def set_client_api_key(api_key)
      @config.set_client_api_key(api_key)
    end

    # Call an API with given options.
    #
    # @return [Http::Response] the response.
    def call_api(http_method, path, opts = {})
      begin
        call_type = opts[:use_read_transporter] || http_method == :GET ? CallType::READ : CallType::WRITE
        response = transporter.request(call_type, http_method, path, opts[:body], opts)
      rescue Faraday::TimeoutError
        raise ApiError, "Connection timed out"
      rescue Faraday::ConnectionFailed
        raise ApiError, "Connection failed"
      end

      response
    end

    # Deserialize the response to the given return type.
    #
    # @param [String] body of the HTTP response
    # @param [String] return_type some examples: "User", "Array<User>", "Hash<String, Integer>"
    def deserialize(body, return_type)
      return nil if body.nil? || body.empty?

      # return response body directly for String return type
      return body.to_s if return_type == "String"

      begin
        data = JSON.parse("[#{body}]", :symbolize_names => true)[0]
      rescue JSON::ParserError => e
        raise e unless %w[String Date Time].include?(return_type)

        data = body
      end

      convert_to_type(data, return_type)
    end

    # Convert data to the given return type.
    # @param [Object] data Data to be converted
    # @param [String] return_type Return type
    # @return [Mixed] Data in a particular type
    def convert_to_type(data, return_type)
      return nil if data.nil?

      case return_type
      when "String"
        data.to_s
      when "Integer"
        data.to_i
      when "Float"
        data.to_f
      when "Boolean"
        data == true
      when "Time"
        # parse date time (expecting ISO 8601 format)
        Time.parse(data)
      when "Date"
        # parse date time (expecting ISO 8601 format)
        Date.parse(data)
      when "Object"
        # generic object (usually a Hash), return directly
        data
      when /\AArray<(.+)>\z/
        # e.g. Array<Pet>
        sub_type = ::Regexp.last_match(1)
        data.map { |item| convert_to_type(item, sub_type) }
      when /\AHash<String, (.+)>\z/
        # e.g. Hash<String, Integer>
        sub_type = ::Regexp.last_match(1)
        {}.tap do |hash|
          data.each { |k, v| hash[k] = convert_to_type(v, sub_type) }
        end
      else
        # models (e.g. Pet), enum, or oneOf
        klass = Algolia.const_get(return_type)
        klass.respond_to?(:openapi_one_of) ? klass.build(data) : klass.build_from_hash(data)
      end
    end

    # Convert object (array, hash, object, etc) to JSON string.
    # @param [Object] model object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_http_body(model)
      return "{}" if model.nil?
      return model if model.is_a?(String)

      body = if model.is_a?(Array)
        model.map { |m| object_to_hash(m) }
      else
        object_to_hash(model)
      end

      body.to_json
    end

    # Convert object(non-array) to hash.
    # @param [Object] obj object to be converted into JSON string
    # @return [String] JSON string representation of the object
    def object_to_hash(obj)
      if obj.is_a?(Hash)
        obj.to_h { |k, v| [k, object_to_hash(v)] }
      elsif obj.respond_to?(:to_hash)
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
        param.join(",")
      when :ssv
        param.join(" ")
      when :tsv
        param.join("\t")
      when :pipes
        param.join("|")
      when :multi
        # return the array directly as typhoeus will handle it as expected
        param
      else
        raise "unknown collection format: #{collection_format.inspect}"
      end
    end
  end
end
