module Algoliasearch
  module Http
    class Response
      attr_reader :status, :body, :error, :headers, :timed_out

      #
      # @option status    [String]  Response status
      # @option body    [String]  Response body
      # @option error    [String]  Response error or caught error
      # @option headers    [String]  Response headers
      # @option timed_out    [String]  If the request has timed out
      #
      def initialize(opts = {})
        @status    = opts[:status] || nil
        @body      = opts[:body] || nil
        @error     = opts[:error] || nil
        @headers   = opts[:headers] || nil
        @timed_out = opts[:timed_out] || false
      end
    end
  end
end
