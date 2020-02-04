module Algolia
  module Http
    class Response
      attr_reader :status, :body, :error, :headers, :has_timed_out

      #
      # @option status    [String]  Response status
      # @option body    [String]  Response body
      # @option error    [String]  Response error or caught error
      # @option headers    [String]  Response headers
      # @option has_timed_out    [String]  If the request has timed out
      #
      def initialize(opts = {})
        @status        = opts[:status]
        @body          = opts[:body]
        @error         = opts[:error]
        @headers       = opts[:headers]
        @has_timed_out = opts[:has_timed_out] || false
      end
    end
  end
end
