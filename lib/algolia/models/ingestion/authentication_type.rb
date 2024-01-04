# Code generated by OpenAPI Generator (https://openapi-generator.tech), manual changes will be lost - read more on https://github.com/algolia/api-clients-automation. DO NOT EDIT.

require 'date'
require 'time'

module Algolia
  module Ingestion
    class AuthenticationType
      GOOGLE_SERVICE_ACCOUNT = "googleServiceAccount".freeze
      BASIC = "basic".freeze
      API_KEY = "apiKey".freeze
      OAUTH = "oauth".freeze
      ALGOLIA = "algolia".freeze

      def self.all_vars
        @all_vars ||= [GOOGLE_SERVICE_ACCOUNT, BASIC, API_KEY, OAUTH, ALGOLIA].freeze
      end

      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def self.build_from_hash(value)
        new.build_from_hash(value)
      end

      # Builds the enum from string
      # @param [String] The enum value in the form of the string
      # @return [String] The enum value
      def build_from_hash(value)
        return value if AuthenticationType.all_vars.include?(value)

        raise "Invalid ENUM value #{value} for class #AuthenticationType"
      end
    end
  end
end