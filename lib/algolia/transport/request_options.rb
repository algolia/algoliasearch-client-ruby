module Algolia
  module Transport
    class RequestOptions
      attr_accessor :header_params, :query_params, :data, :timeout, :connect_timeout, :compression_type

      # @param [Search::Config] config
      #
      def initialize(config)
        @header_params = {}
        @query_params = {}
        @timeout = nil
        @connect_timeout = nil
        @compression_type = config.compression_type
      end

      # Create and format headers and query params from request options
      #
      # @param opts [Hash]
      #
      def create(opts = {})
        add_header_params(opts)
        add_query_params(opts)
        add_timeout(opts)
        add_connect_timeout(opts)
        add_compression_type(opts)
      end

      # Add or update header_params
      #
      # @param opts [Hash]
      #
      def add_header_params(opts = {})
        return if opts[:header_params].nil?

        opts[:header_params].each do |opt, value|
          @header_params[opt.to_s] = value
        end

        opts.delete(:header_params)
      end

      # Add or update query parameters
      #
      # @param opts [Hash]
      #
      def add_query_params(opts = {})
        return if opts[:query_params].nil?

        opts[:query_params].each do |opt, value|
          @query_params[opt.to_sym] = value
        end

        opts.delete(:query_params)
      end

      # Add or update timeout
      #
      # @param opts [Hash]
      #
      def add_timeout(opts = {})
        @timeout = opts[:timeout] || @timeout
        opts.delete(:timeout)
      end

      # Add or update connect timeout
      #
      # @param opts [Hash]
      #
      def add_connect_timeout(opts = {})
        @connect_timeout = opts[:connect_timeout] || @connect_timeout
        opts.delete(:connect_timeout)
      end

      # Add or update compression_type
      #
      # @param opts [Hash]
      #
      def add_compression_type(opts = {})
        @compression_type = opts[:compression_type] || @compression_type
        opts.delete(:compression_type)
      end
    end
  end
end
