require 'algolia/version'
require 'algolia/helpers'
require 'algolia/http/http_requester'
require 'algolia/defaults'
require 'algolia/user_agent'
require 'algolia/config/algolia_config'
require 'algolia/config/search_config'
require 'algolia/enums/call_type'
require 'algolia/enums/retry_outcome_type'
require 'algolia/iterators/base_iterator'
require 'algolia/iterators/object_iterator'
require 'algolia/http/response'
require 'algolia/transport/request_options'
require 'algolia/transport/transport'
require 'algolia/transport/retry_strategy'
require 'algolia/transport/stateful_host'
require 'algolia/search_client'
require 'algolia/error'
require 'algolia/search_index'
require 'algolia/logger_helper'

# Algolia module
module Algolia
end
