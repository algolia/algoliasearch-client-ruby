# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

require "date"
require "time"

module Algolia
  module Search
    # userIDs data.
    class SearchUserIdsResponse
      # User objects that match the query.
      attr_accessor :hits

      # Number of results (hits).
      attr_accessor :nb_hits

      # Page of search results to retrieve.
      attr_accessor :page

      # Maximum number of hits per page.
      attr_accessor :hits_per_page

      # Date and time when the object was updated, in RFC 3339 format.
      attr_accessor :updated_at

      # Attribute mapping from ruby-style variable name to JSON key.
      def self.attribute_map
        {
          :hits => :hits,
          :nb_hits => :nbHits,
          :page => :page,
          :hits_per_page => :hitsPerPage,
          :updated_at => :updatedAt
        }
      end

      # Returns all the JSON keys this model knows about
      def self.acceptable_attributes
        attribute_map.values
      end

      # Attribute type mapping.
      def self.types_mapping
        {
          :hits => :"Array<UserHit>",
          :nb_hits => :"Integer",
          :page => :"Integer",
          :hits_per_page => :"Integer",
          :updated_at => :"String"
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
          raise(
            ArgumentError,
            "The input argument (attributes) must be a hash in `Algolia::SearchUserIdsResponse` initialize method"
          )
        end

        # check to see if the attribute exists and convert string to symbol for hash key
        attributes = attributes.each_with_object({}) { |(k, v), h|
          if (!self.class.attribute_map.key?(k.to_sym))
            raise(
              ArgumentError,
              "`#{k}` is not a valid attribute in `Algolia::SearchUserIdsResponse`. Please check the name to make sure it's valid. List of attributes: " +
                self.class.attribute_map.keys.inspect
            )
          end

          h[k.to_sym] = v
        }

        if attributes.key?(:hits)
          if (value = attributes[:hits]).is_a?(Array)
            self.hits = value
          end
        else
          self.hits = nil
        end

        if attributes.key?(:nb_hits)
          self.nb_hits = attributes[:nb_hits]
        else
          self.nb_hits = nil
        end

        if attributes.key?(:page)
          self.page = attributes[:page]
        else
          self.page = nil
        end

        if attributes.key?(:hits_per_page)
          self.hits_per_page = attributes[:hits_per_page]
        else
          self.hits_per_page = nil
        end

        if attributes.key?(:updated_at)
          self.updated_at = attributes[:updated_at]
        else
          self.updated_at = nil
        end
      end

      # Custom attribute writer method with validation
      # @param [Object] page Value to be assigned
      def page=(page)
        if page.nil?
          raise ArgumentError, "page cannot be nil"
        end

        if page < 0
          raise ArgumentError, "invalid value for \"page\", must be greater than or equal to 0."
        end

        @page = page
      end

      # Custom attribute writer method with validation
      # @param [Object] hits_per_page Value to be assigned
      def hits_per_page=(hits_per_page)
        if hits_per_page.nil?
          raise ArgumentError, "hits_per_page cannot be nil"
        end

        if hits_per_page > 1000
          raise ArgumentError, "invalid value for \"hits_per_page\", must be smaller than or equal to 1000."
        end

        if hits_per_page < 1
          raise ArgumentError, "invalid value for \"hits_per_page\", must be greater than or equal to 1."
        end

        @hits_per_page = hits_per_page
      end

      # Checks equality by comparing each attribute.
      # @param [Object] Object to be compared
      def ==(other)
        return true if self.equal?(other)
        self.class == other.class &&
          hits == other.hits &&
          nb_hits == other.nb_hits &&
          page == other.page &&
          hits_per_page == other.hits_per_page &&
          updated_at == other.updated_at
      end

      # @see the `==` method
      # @param [Object] Object to be compared
      def eql?(other)
        self == other
      end

      # Calculates hash code according to all attributes.
      # @return [Integer] Hash code
      def hash
        [hits, nb_hits, page, hits_per_page, updated_at].hash
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
