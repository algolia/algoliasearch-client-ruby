require 'faraday'
require 'json'

module Algoliasearch
  # Class AlgoliaConfig
  class AlgoliaConfig
    attr_accessor :app_id, :api_key, :default_hosts, :custom_hosts, :default_headers, :batch_size, :read_timeout, :write_timeout, :connect_timeout, :compression_type

    #
    # @option options [String] :app_id
    # @option options [String] :api_key
    # @option options [Integer] :batch_size
    # @option options [Integer] :read_timeout
    # @option options [Integer] :write_timeout
    # @option options [Integer] :connect_timeout
    #
    def initialize(options = {})
      @app_id = options[:app_id] || ENV['ALGOLIA_APP_ID']
      @api_key = options[:api_key] || ENV['ALGOLIA_API_KEY']
      raise ArgumentError, 'No APPLICATION_ID provided, please set :application_id' if @app_id.nil?

      @default_headers = {
        'X-Algolia-Application-Id': app_id,
        'X-Algolia-API-Key': api_key,
        'User-Agent': UserAgent.value,
        'Content-Type': 'application/json'
      }

      @batch_size = options[:batch_size] || 1000
      @read_timeout = options[:read_timeout] || 5
      @write_timeout = options[:write_timeout] || 30
      @connect_timeout = options[:connect_timeout] || 2
    end
  end
end
