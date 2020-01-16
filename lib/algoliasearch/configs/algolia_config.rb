require 'faraday'

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
    def initialize(opts = {})
      @app_id = opts[:app_id] || ENV['ALGOLIA_APP_ID']
      @api_key = opts[:api_key] || ENV['ALGOLIA_API_KEY']
      raise ArgumentError, 'No APPLICATION_ID provided, please set :application_id' if @app_id.nil?

      @default_headers = {
        Http::Protocol::HEADER_API_KEY => @api_key,
          Http::Protocol::HEADER_APP_ID => @app_id,
          'Content-Type'           => 'application/json; charset=utf-8',
          'User-Agent'             => DEFAULT_USER_AGENT.push(opts[:user_agent]).uniq.compact.join('; ')
      }

      @batch_size = opts[:batch_size] || 1000
      @read_timeout = opts[:read_timeout] || 5
      @write_timeout = opts[:write_timeout] || 30
      @connect_timeout = opts[:connect_timeout] || 2
    end
  end
end
