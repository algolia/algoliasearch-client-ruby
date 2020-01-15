module Algoliasearch
  module Transport
    class Response
      attr_reader :status, :body, :headers

      #
      # @param status  [Integer] Response status code
      # @param body    [String]  Response body
      # @param headers [Hash]    Response headers
      #
      def initialize(status, body, headers = {})
        @status = status
        @body = body
        @headers = headers
      end
    end
  end
end
