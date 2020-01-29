module Algoliasearch
  module Http
    class RequestOptions
      attr_accessor :headers, :params, :timeouts

      #
      # @param [SearchConfig] config
      #
      def initialize(config)
        @headers = config.default_headers
        @params  = {}
      end

      # Create and format headers and params from request options
      #
      # @param opts [Hash]
      #
      def create(opts = {})
        add_headers(opts)
        add_params(opts)
      end

      # Add or update headers
      #
      # @param opts [Hash]
      #
      def add_headers(opts = {})
        opts.each do |opt, value|
          option = Helpers.to_string(opt)
          if Defaults::VALID_HEADERS.include?(option) || @headers.include?(option)
            @headers[opt] = value
          end
        end
      end

      # Add or update query parameters
      #
      # @param opts [Hash]
      #
      def add_params(opts = {})
        opts.each do |opt, value|
          option = Helpers.to_string(opt)
          if Defaults::VALID_QUERY_PARAMS.include?(option) || @params.include?(option)
            @params[opt] = value
          end
        end
      end
    end
  end
end
