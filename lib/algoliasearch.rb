require 'logger'
require 'multi_json'

require 'algoliasearch/config/algolia_config'
require 'algoliasearch/config/search_config'
require 'algoliasearch/enums/call_type'
require 'algoliasearch/enums/retry_outcome_type'
require 'algoliasearch/http/http_requester'
require 'algoliasearch/http/response'
require 'algoliasearch/http/request_options'
require 'algoliasearch/transport/transport'
require 'algoliasearch/transport/retry_strategy'
require 'algoliasearch/transport/stateful_host'
require 'algoliasearch/search_client'
require 'algoliasearch/defaults'
require 'algoliasearch/error'
require 'algoliasearch/search_index'
require 'algoliasearch/logger_helper'
require 'algoliasearch/helpers'
require 'algoliasearch/version'

# Algolia module
module Algolia
end
