begin
  require 'webmock'
rescue LoadError
  puts 'WebMock was not found, please add "gem \'webmock\'" to your Gemfile.'
  exit 1
end

module Algolia
  class WebMock
    def self.mock!
      # list indexes
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes}).to_return(body: '{ "items": [] }')
      # query index
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+}).to_return(body: '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1, "nbHits": 1, "nbPages": 1 }')
      # delete index
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+}).to_return(body: '{ "taskID": 42 }')
      # clear index
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/clear}).to_return(body: '{ "taskID": 42 }')
      # add object
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+}).to_return(body: '{ "taskID": 42 }')
      # save object
      ::WebMock.stub_request(:put, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/[^/]+}).to_return(body: '{ "taskID": 42 }')
      # partial update
      ::WebMock.stub_request(:put, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/[^/]+/partial}).to_return(body: '{ "taskID": 42 }')
      # get object
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/[^/]+}).to_return(body: '{}')
      # delete object
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/[^/]+}).to_return(body: '{ "taskID": 42 }')
      # delete by
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/deleteByQuery}).to_return(body: '{ "taskID": 42 }')
      # batch
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/batch}).to_return(body: '{ "taskID": 42 }')
      # settings
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/settings}).to_return(body: '{}')
      ::WebMock.stub_request(:put, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/settings}).to_return(body: '{ "taskID": 42 }')
      # browse
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/browse}).to_return(body: '{ "hits": [] }')
      # operations
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/operation}).to_return(body: '{ "taskID": 42 }')
      # tasks
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/task/[^/]+}).to_return(body: '{ "status": "published" }')
      # index keys
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/keys}).to_return(body: '{ }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/keys}).to_return(body: '{ "keys": [] }')
      # global keys
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/keys}).to_return(body: '{ }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/keys}).to_return(body: '{ "keys": [] }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/keys/[^/]+}).to_return(body: '{ }')
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/keys/[^/]+}).to_return(body: '{ }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/keys/[^/]+/restore}).to_return(body: '{ "keys": "42" }')
      # query POST
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/query}).to_return(body: '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1, "nbHits": 1, "nbPages": 1 }')
      # multiple operations
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/objects}).to_return(body: '{ "results": [ ] }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/queries}).to_return(body: '{ "results": [ ] }')
      # clusters
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings}).to_return(body: '{ "createdAt": "" }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings/batch}).to_return(body: '{ "createdAt": "" }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings/top}).to_return(body: '{ "topUsers": [] }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings/[^/]+}).to_return(body: '{ "userID": "user42" }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/clusters}).to_return(body: '{ "clusters": [] }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings}).to_return(body: '{ "userIDs": [] }')
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings}).to_return(body: '{ "deletedAt": "" }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings/search}).to_return(body: '{ "hits": [] }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/clusters/mappings/pending}).to_return(body: '{ "createdAt": "" }')
      # rules
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/rules/batch}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/rules/[^/]+}).to_return(body: '{ "objectID": "42" }')
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/rules/[^/]+}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/rules/clear}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/rules/search}).to_return(body: '{ "hits": [] }')
      # synonyms
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/synonyms/batch}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/synonyms/[^/]+}).to_return(body: '{ "objectID": "42" }')
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/synonyms/[^/]+}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/synonyms/clear}).to_return(body: '{ "taskID": 42 }')
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/synonyms/search}).to_return(body: '{ "hits": [] }')
      # facets
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/indexes/[^/]+/facets/[^/]+/query}).to_return(body: '{ "facetHits": [] }')
      # get logs
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/logs}).to_return(body: '{ "logs": [ ] }')
      # add ab_test
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/2/abtests}).to_return(body: '{ "taskID": 42 }')
      # get ab test
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/2/abtests/[^/]+}).to_return(body: '{ "abTestID": 42 }')
      # get ab tests
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/2/abtests}).to_return(body: '{ "abtests": [] }')
      # stop ab tests
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/2/abtests/[^/]+/stop}).to_return(body: '{ "status": 200 }')
      # delete ab tests
      ::WebMock.stub_request(:delete, %r{.*\.algolia(net\.com|\.net)/2/abtests/[^/]+}).to_return(body: '{ "status": 200 }')
      # send events
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/events}).to_return(body: '{ "status": 200 }')
      # set personalization strategy
      ::WebMock.stub_request(:post, %r{.*\.algolia(net\.com|\.net)/1/strategies/personalization}).to_return(body: '{ "status": 200 }')
      # get personalization strategy
      ::WebMock.stub_request(:get, %r{.*\.algolia(net\.com|\.net)/1/strategies/personalization}).to_return(body: '{ "eventsScoring": { } }')
    end
  end
end

Algolia::WebMock.mock!
