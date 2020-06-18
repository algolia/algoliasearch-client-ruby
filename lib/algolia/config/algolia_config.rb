require 'faraday'

module Algolia
  # Class AlgoliaConfig
  class AlgoliaConfig
    attr_accessor :app_id, :api_key, :default_headers, :batch_size, :read_timeout, :write_timeout, :connect_timeout, :compression_type,
                  :symbolize_keys

    #
    # @option options [String] :app_id
    # @option options [String] :api_key
    # @option options [Integer] :batch_size
    # @option options [Integer] :read_timeout
    # @option options [Integer] :write_timeout
    # @option options [Integer] :connect_timeout
    # @option options [Boolean] :symbolize_keys
    #
    def initialize(opts = {})
      raise ArgumentError, 'No Application ID provided, please set :app_id' unless opts.has_key?(:app_id)
      raise ArgumentError, 'No API key provided, please set :api_key' unless opts.has_key?(:api_key)

      @app_id  = opts[:app_id]
      @api_key = opts[:api_key]

      @default_headers = {
        Defaults::HEADER_API_KEY => @api_key,
        Defaults::HEADER_APP_ID => @app_id,
        'Content-Type' => 'application/json; charset=utf-8',
        'User-Agent' => UserAgent.value
      }

      @batch_size       = opts[:batch_size] || Defaults::BATCH_SIZE
      @read_timeout     = opts[:read_timeout] || Defaults::READ_TIMEOUT
      @write_timeout    = opts[:write_timeout] || Defaults::WRITE_TIMEOUT
      @connect_timeout  = opts[:connect_timeout] || Defaults::CONNECT_TIMEOUT
      @compression_type = opts[:compression_type] || Defaults::NONE_ENCODING
      @symbolize_keys   = opts[:symbolize_keys] || true
    end
  end
end