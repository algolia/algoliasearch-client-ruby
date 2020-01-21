module Algoliasearch
  module Transport
    # Class StatefulHost
    class StatefulHost
      include CallType

      attr_reader :url, :protocol, :accept
      attr_accessor :last_use, :retry_count, :up

      #
      # @param url [String] host url
      # @option options [binary] :accept accept type flag
      # @option options [DateTime] :last_use last usage date
      # @option options [Integer] :retry_count number of retries
      # @option options [Boolean] :up host status
      #
      def initialize(url, options = {})
        @url = url
        @protocol = options[:protocol] || 'https://'
        @accept = options[:accept] || (READ | WRITE)
        @last_use = options[:last_use] || Time.now.utc
        @retry_count = options[:retry_count] || 0
        @up = options.has_key?(:up) ? options[:up] : true
      end
    end
  end
end
