module Algolia
  # Base exception class for errors thrown by the Algolia
  # client library. AlgoliaError will be raised by any
  # network operation if Algolia.init() has not been called.
  # Exception ... why? A:http://www.skorks.com/2009/09/ruby-exceptions-and-exception-handling/
  #
  class AlgoliaError < StandardError
  end

  # Used when hosts are unreachable
  #
  class AlgoliaUnreachableHostError < AlgoliaError
    attr_reader :errors

    # The last non-empty Correlation-ID header among the retried attempts, or nil.
    # Quote it when contacting Algolia support.
    attr_reader :correlation_id

    def initialize(message, errors = [], correlation_id = nil)
      errors.last&.tap do |last_error|
        message += " Last error for #{last_error[:host]}: #{last_error[:error]}"
      end

      message += " (Correlation-ID: #{correlation_id})" unless correlation_id.nil? || correlation_id.empty?

      super(message)
      @errors = errors
      @correlation_id = correlation_id
    end
  end

  # An exception class raised when the REST API returns an error.
  # The error code and message will be parsed out of the HTTP response,
  # which is also included in the response attribute.
  #
  class AlgoliaHttpError < AlgoliaError
    attr_accessor :code, :http_message

    # The Correlation-ID header of the failed response (possibly ""), or nil.
    # Quote it when contacting Algolia support.
    attr_reader :correlation_id

    def initialize(code, message, correlation_id = nil)
      self.code = code
      self.http_message = message
      @correlation_id = correlation_id

      if correlation_id.nil? || correlation_id.empty?
        super("#{code}: #{message}")
      else
        super("#{code}: #{message} (Correlation-ID: #{correlation_id})")
      end
    end
  end
end
