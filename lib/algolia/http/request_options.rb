module Algolia
  module Http
    class RequestOptions
      attr_accessor :headers, :params, :timeout, :compression_type

      #
      # @param [Search::Config] config
      #
      def initialize(config)
        @headers          = {}
        @params           = {}
        @timeout          = nil
        @compression_type = config.compression_type
      end

      # Create and format headers and params from request options
      #
      # @param opts [Hash]
      #
      def create(opts = {})
        add_headers(opts)
        add_params(opts)
        add_timeout(opts)
        add_compression_type(opts)
        opts
      end

      # Add or update headers
      #
      # @param opts [Hash]
      #
      def add_headers(opts = {})
        unless opts[:headers].nil?
          opts[:headers].each do |opt, value|
            @params[opt.to_sym] = value
          end
          opts.delete(:headers)
        end
      end

      # Add or update query parameters
      #
      # @param opts [Hash]
      #
      def add_params(opts = {})
        unless opts[:params].nil?
          opts[:params].each do |opt, value|
            @params[opt.to_sym] = value
          end
          opts.delete(:params)
        end
      end

      # Add or update timeout
      #
      # @param opts [Hash]
      #
      def add_timeout(opts = {})
        @timeout = opts[:timeout] || @timeout
        opts.delete(:timeout)
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
