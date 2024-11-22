# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

require "date"
require "time"

module Algolia
  module Search
    class Log
      # Date and time of the API request, in RFC 3339 format.
      attr_accessor :timestamp

      # HTTP method of the request.
      attr_accessor :method

      # HTTP status code of the response.
      attr_accessor :answer_code

      # Request body.
      attr_accessor :query_body

      # Response body.
      attr_accessor :answer

      # URL of the API endpoint.
      attr_accessor :url

      # IP address of the client that performed the request.
      attr_accessor :ip

      # Request headers (API keys are obfuscated).
      attr_accessor :query_headers

      # SHA1 signature of the log entry.
      attr_accessor :sha1

      # Number of API requests.
      attr_accessor :nb_api_calls

      # Processing time for the query in milliseconds. This doesn't include latency due to the network.
      attr_accessor :processing_time_ms

      # Index targeted by the query.
      attr_accessor :index

      # Query parameters sent with the request.
      attr_accessor :_query_params

      # Number of search results (hits) returned for the query.
      attr_accessor :query_nb_hits

      # Queries performed for the given request.
      attr_accessor :inner_queries

      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :timestamp => :timestamp,
          :method => :method,
          :answer_code => :answer_code,
          :query_body => :query_body,
          :answer => :answer,
          :url => :url,
          :ip => :ip,
          :query_headers => :query_headers,
          :sha1 => :sha1,
          :nb_api_calls => :nb_api_calls,
          :processing_time_ms => :processing_time_ms,
          :index => :index,
          :_query_params => :query_params,
          :query_nb_hits => :query_nb_hits,
          :inner_queries => :inner_queries
        }
      end

      # Returns all the JSON keys this model knows about
      def self.acceptable_attributes
        attribute_map.values
      end

      # Attribute type mapping.
      def self.types_mapping
        {
          :timestamp => :"String",
          :method => :"String",
          :answer_code => :"String",
          :query_body => :"String",
          :answer => :"String",
          :url => :"String",
          :ip => :"String",
          :query_headers => :"String",
          :sha1 => :"String",
          :nb_api_calls => :"String",
          :processing_time_ms => :"String",
          :index => :"String",
          :_query_params => :"String",
          :query_nb_hits => :"String",
          :inner_queries => :"Array<LogQuery>"
        }
      end

      # List of attributes with nullable: true
      def self.openapi_nullable
        Set.new(
          []
        )
      end

      # Initializes the object
      # @param [Hash] attributes Model attributes in the form of hash
      def initialize(attributes = {})
        if (!attributes.is_a?(Hash))
          raise ArgumentError, "The input argument (attributes) must be a hash in `Algolia::Log` initialize method"
        end

        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            raise(
              ArgumentError,
              "`#{k}` is not a valid attribute in `Algolia::Log`. Please check the name to make sure it's valid. List of attributes: " +
                self.class.attribute_map.keys.inspect
            )
          end

          h[k.to_sym] = v
        }

        if attributes.key?(:timestamp)
          self.timestamp = attributes[:timestamp]
        else
          self.timestamp = nil
        end

        if attributes.key?(:method)
          self.method = attributes[:method]
        else
          self.method = nil
        end

        if attributes.key?(:answer_code)
          self.answer_code = attributes[:answer_code]
        else
          self.answer_code = nil
        end

        if attributes.key?(:query_body)
          self.query_body = attributes[:query_body]
        else
          self.query_body = nil
        end

        if attributes.key?(:answer)
          self.answer = attributes[:answer]
        else
          self.answer = nil
        end

        if attributes.key?(:url)
          self.url = attributes[:url]
        else
          self.url = nil
        end

        if attributes.key?(:ip)
          self.ip = attributes[:ip]
        else
          self.ip = nil
        end

        if attributes.key?(:query_headers)
          self.query_headers = attributes[:query_headers]
        else
          self.query_headers = nil
        end

        if attributes.key?(:sha1)
          self.sha1 = attributes[:sha1]
        else
          self.sha1 = nil
        end

        if attributes.key?(:nb_api_calls)
          self.nb_api_calls = attributes[:nb_api_calls]
        end

        if attributes.key?(:processing_time_ms)
          self.processing_time_ms = attributes[:processing_time_ms]
        else
          self.processing_time_ms = nil
        end

        if attributes.key?(:index)
          self.index = attributes[:index]
        end

        if attributes.key?(:_query_params)
          self._query_params = attributes[:_query_params]
        end

        if attributes.key?(:query_nb_hits)
          self.query_nb_hits = attributes[:query_nb_hits]
        end

        if attributes.key?(:inner_queries)
          if (value = attributes[:inner_queries]).is_a?(Array)
            self.inner_queries = value
          end
        end
      end

      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(other)
        return true if self.equal?(other)
        self.class == other.class &&
          timestamp == other.timestamp &&
          method == other.method &&
          answer_code == other.answer_code &&
          query_body == other.query_body &&
          answer == other.answer &&
          url == other.url &&
          ip == other.ip &&
          query_headers == other.query_headers &&
          sha1 == other.sha1 &&
          nb_api_calls == other.nb_api_calls &&
          processing_time_ms == other.processing_time_ms &&
          index == other.index &&
          _query_params == other._query_params &&
          query_nb_hits == other.query_nb_hits &&
          inner_queries == other.inner_queries
      end

      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(other)
        self == other
      end

      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [
          timestamp,
          method,
          answer_code,
          query_body,
          answer,
          url,
          ip,
          query_headers,
          sha1,
          nb_api_calls,
          processing_time_ms,
          index,
          _query_params,
          query_nb_hits,
          inner_queries
        ].hash
      end

      # Builds the object from hash
      # @param [Hash] attributes Model attributes in the form of hash
      # @return [Object] Returns the model itself
      def self.build_from_hash(attributes)
        return nil unless attributes.is_a?(Hash)
        attributes = attributes.transform_keys(&:to_sym)
        transformed_hash = {}
        types_mapping.each_pair do |key, type|
          if attributes.key?(attribute_map[key]) && attributes[attribute_map[key]].nil?
            transformed_hash[key.to_sym] = nil
          elsif type =~ /\AArray<(.*)>/i
            # check to ensure the input is an array given that the attribute
            # is documented as an array but the input is not
            if attributes[attribute_map[key]].is_a?(Array)
              transformed_hash[key.to_sym] = attributes[attribute_map[key]].map { |v|
                _deserialize(::Regexp.last_match(1), v)
              }
            end
          elsif !attributes[attribute_map[key]].nil?
            transformed_hash[key.to_sym] = _deserialize(type, attributes[attribute_map[key]])
          end
        end

        new(transformed_hash)
      end

      # Deserializes the data based on type
      # @param string type Data type
      # @param string value Value to be deserialized
      # @return [Object] Deserialized data
      def self._deserialize(type, value)
        case type.to_sym
        when :Time
          Time.parse(value)
        when :Date
          Date.parse(value)
        when :String
          value.to_s
        when :Integer
          value.to_i
        when :Float
          value.to_f
        when :Boolean
          if value.to_s =~ /\A(true|t|yes|y|1)\z/i
            true
          else
            false
          end

        when :Object
          # generic object (usually a Hash), return directly
          value
        when /\AArray<(?<inner_type>.+)>\z/
          inner_type = Regexp.last_match[:inner_type]
          value.map { |v| _deserialize(inner_type, v) }
        when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
          k_type = Regexp.last_match[:k_type]
          v_type = Regexp.last_match[:v_type]
          {}.tap do |hash|
            value.each do |k, v|
              hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
            end
          end
          # model
        else
          # models (e.g. Pet) or oneOf
          klass = Algolia::Search.const_get(type)
          klass.respond_to?(:openapi_any_of) || klass.respond_to?(:openapi_one_of) ? klass.build(value) : klass
            .build_from_hash(value)
        end
      end

      # Returns the string representation of the object
      # @return [String] String presentation of the object
      def to_s
        to_hash.to_s
      end

      # to_body is an alias to to_hash (backward compatibility)
      # @return [Hash] Returns the object in the form of hash
      def to_body
        to_hash
      end

      def to_json(*_args)
        to_hash.to_json
      end

      # Returns the object in the form of hash
      # @return [Hash] Returns the object in the form of hash
      def to_hash
        hash = {}
        self.class.attribute_map.each_pair do |attr, param|
          value = send(attr)
          if value.nil?
            is_nullable = self.class.openapi_nullable.include?(attr)
            next if !is_nullable || (is_nullable && !instance_variable_defined?(:"@#{attr}"))
          end

          hash[param] = _to_hash(value)
        end

        hash
      end

      # Outputs non-array value in the form of hash
      # For object, use to_hash. Otherwise, just return the value
      # @param [Object] value Any valid value
      # @return [Hash] Returns the value in the form of hash
      def _to_hash(value)
        if value.is_a?(Array)
          value.compact.map { |v| _to_hash(v) }
        elsif value.is_a?(Hash)
          {}.tap do |hash|
            value.each { |k, v| hash[k] = _to_hash(v) }
          end
        elsif value.respond_to?(:to_hash)
          value.to_hash
        else
          value
        end
      end

    end

  end
end
