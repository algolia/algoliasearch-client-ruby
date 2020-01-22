module Defaults
  REQUESTER_CLASS = Algoliasearch::Http::HttpRequester
  TTL = 300
  # The version of the REST API implemented by this module.
  VERSION = 1

  # HTTP Headers
  # ----------------------------------------

  # The HTTP header used for passing your application ID to the Algolia API.
  HEADER_APP_ID            = 'X-Algolia-Application-Id'.freeze

  # The HTTP header used for passing your API key to the Algolia API.
  HEADER_API_KEY           = 'X-Algolia-API-Key'.freeze
  HEADER_FORWARDED_IP      = 'X-Forwarded-For'.freeze
  HEADER_FORWARDED_API_KEY = 'X-Forwarded-API-Key'.freeze

  # HTTP ERROR CODES
  # ----------------------------------------

  ERROR_BAD_REQUEST = 400
  ERROR_FORBIDDEN = 403
  ERROR_NOT_FOUND = 404

  BATCH_SIZE      = 1000
  CONNECT_TIMEOUT = 2
  READ_TIMEOUT = 30
  WRITE_TIMEOUT = 5
  USER_AGENT = ["Algolia for Ruby (#{::Algoliasearch::VERSION})", "Ruby (#{RUBY_VERSION})"]

  TIMED_OUT_STATUS = 408
end
