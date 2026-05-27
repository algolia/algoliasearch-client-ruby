# frozen_string_literal: true

# Common files
require "algolia/api_client"
require "algolia/api_error"
require "algolia/chunked_helper_options"
require "algolia/defaults"
require "algolia/error"
require "algolia/version"
require "algolia/configuration"
require "algolia/user_agent"
require "algolia/logger_helper"
require "algolia/transport/http/http_requester"
require "algolia/transport/http/response"
require "algolia/transport/echo_requester"
require "algolia/transport/call_type"
require "algolia/transport/retry_outcome_type"
require "algolia/transport/stateful_host"
require "algolia/transport/retry_strategy"
require "algolia/transport/request_options"
require "algolia/transport/transport"

# Models
Dir["#{File.dirname(__FILE__)}/algolia/models/**/*.rb"].sort.each { |file| require file }

# APIs
Dir["#{File.dirname(__FILE__)}/algolia/api/*.rb"].sort.each { |file| require file }

module Algolia
end
