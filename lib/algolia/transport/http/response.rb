module Algolia
  module Http
    class Response
      attr_reader :status, :reason_phrase, :body, :error, :headers, :has_timed_out, :network_failure

      # used for the echo requester
      attr_reader :method, :path, :query_params, :host, :timeout, :connect_timeout

      #
      # @option status    [String]  Response status
      # @option reason_phrase    [String]  Response reason phrase
      # @option body    [String]  Response body
      # @option error    [String]  Response error or caught error
      # @option headers    [String]  Response headers
      # @option has_timed_out    [String]  If the request has timed out
      #
      def initialize(opts = {})
        @status = opts[:status]
        @reason_phrase = opts[:reason_phrase]
        @body = opts[:body]
        @error = opts[:error] || ""
        @headers = opts[:headers] || ""
        @has_timed_out = opts[:has_timed_out] || false
        @network_failure = opts[:network_failure] || false

        @method = opts[:method] || ""
        @path = opts[:path] || ""
        @host = opts[:host] || ""
        @timeout = opts[:timeout] || 0
        @connect_timeout = opts[:connect_timeout] || 0
        @query_params = opts[:query_params] || {}
      end
    end
  end
end
