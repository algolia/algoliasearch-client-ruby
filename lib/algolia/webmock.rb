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
      mock_request(:get, '/1/indexes', { body: '{ "items": [] }' })
      # query index
      mock_request(:get, '/1/indexes/%s', { body: '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1, "nbHits": 1, "nbPages": 1 }' })
      # delete index
      mock_request(:delete, '/1/indexes/%s', { body: '{ "taskID": 42 }' })
      # clear index
      mock_request(:post, '/1/indexes/%s/clear', { body: '{ "taskID": 42 }' })
      # add object
      mock_request(:post, '/1/indexes/%s', { body: '{ "taskID": 42 }' })
      # save object
      mock_request(:put, '/1/indexes/%s/%s', { body: '{ "taskID": 42 }' })
      # partial update
      mock_request(:put, '/1/indexes/%s/%s/partial', { body: '{ "taskID": 42 }' })
      # get object
      mock_request(:get, '/1/indexes/%s/%s', { body: '{}' })
      # delete object
      mock_request(:delete, '/1/indexes/%s/%s', { body: '{ "taskID": 42 }' })
      # delete by
      mock_request(:post, '/1/indexes/%s/deleteByQuery', { body: '{ "taskID": 42 }' })
      # batch
      mock_request(:post, '/1/indexes/%s/batch', { body: '{ "taskID": 42 }' })
      # settings
      mock_request(:delete, '/1/indexes/%s/settings', { body: '{}' })
      mock_request(:put, '/1/indexes/%s/settings', { body: '{ "taskID": 42 }' })
      # browse
      mock_request(:get, '/1/indexes/%s/browse', { body: '{ "hits": [] }' })
      # operations
      mock_request(:post, '/1/indexes/%s/operation', { body: '{ "taskID": 42 }' })
      # tasks
      mock_request(:get, '/1/indexes/%s/task/%s', { body: '{ "status": "published" }' })
      # index keys
      mock_request(:post, '/1/indexes/%s/keys', { body: '{}' })
      mock_request(:get, '/1/indexes/%s/keys', { body: '{ "keys": [] }' })
      # global keys
      mock_request(:post, '/1/keys', { body: '{ }' })
      mock_request(:get, '/1/keys', { body: '{ "keys": [] }' })
      mock_request(:get, '/1/keys/%s', { body: '{ }' })
      mock_request(:delete, '/1/keys/%s', { body: '{ }' })
      mock_request(:post, '/1/keys/%s/restore', { body: '{ "keys": "42" }' })
      # query POST
      mock_request(:post, '/1/indexes/%s/query', { body: '{ "hits": [ { "objectID": 42 } ], "page": 1, "hitsPerPage": 1, "nbHits": 1, "nbPages": 1 }' })
      # multiple operations
      mock_request(:post, '/1/indexes/%s/objects', { body: '{ "results": [ ] }' })
      mock_request(:post, '/1/indexes/%s/queries', { body: '{ "results": [ ] }' })
      # clusters
      mock_request(:post, '/1/clusters/mappings', { body: '{ "createdAt": "" }' })
      mock_request(:post, '/1/clusters/mappings/batch', { body: '{ "createdAt": "" }' })
      mock_request(:get, '/1/clusters/mappings/top', { body: '{ "topUsers": [] }' })
      mock_request(:get, '/1/clusters/mappings/%s', { body: '{ "userID": "user42" }' })
      mock_request(:get, '/1/clusters', { body: '{ "clusters": [] }' })
      mock_request(:get, '/1/clusters/mappings', { body: '{ "userIDs": [] }' })
      mock_request(:delete, '/1/clusters/mappings', { body: '{ "deletedAt": "" }' })
      mock_request(:post, '/1/clusters/mappings/search', { body: '{ "hits": [] }' })
      mock_request(:get, '/1/clusters/mappings/pending', { body: '{ "createdAt": "" }' })
      # rules
      mock_request(:post, '/1/indexes/%s/rules/batch', { body: '{ "taskID": 42 }' })
      mock_request(:get, '/1/indexes/%s/rules/%s', { body: '{ "objectID": "42" }' })
      mock_request(:delete, '/1/indexes/%s/rules/%s', { body: '{ "taskID": 42 }' })
      mock_request(:post, '/1/indexes/%s/rules/clear', { body: '{ "taskID": 42 }' })
      mock_request(:post, '/1/indexes/%s/rules/search', { body: '{ "hits": [] }' })
      # synonyms
      mock_request(:post, '/1/indexes/%s/synonyms/batch', { body: '{ "taskID": 42 }' })
      mock_request(:get, '/1/indexes/%s/synonyms/%s', { body: '{ "objectID": 42 }' })
      mock_request(:delete, '/1/indexes/%s/synonyms/%s', { body: '{ "taskID": 42 }' })
      mock_request(:post, '/1/indexes/%s/synonyms/clear', { body: '{ "taskID": 42 }' })
      mock_request(:post, '/1/indexes/%s/synonyms/search', { body: '{ "hits": [] }' })
      # facets
      mock_request(:post, '/1/indexes/%s/facets/%s/query', { body: '{ "facetHits": [] }' })
      # get logs
      mock_request(:get, '/1/logs', { body: '{ "logs": [ ] }' })
      # ab_tests
      mock_request(:post, '/2/abtests', { body: '{ "taskID": 42 }' })
      mock_request(:get, '/2/abtests/%s', { body: '{ "abTestID": 42 }' })
      mock_request(:get, '/2/abtests/%s', { body: '{ "abtests": [] }' })
      mock_request(:post, '/2/abtests/%s/stop', { body: '{ "status": 200 }' })
      mock_request(:delete, '/2/abtests/%s', { body: '{ "status": 200 }' })
      # send events
      mock_request(:post, '/1/events', { body: '{ "status": 200 }' })
      # set personalization strategy
      mock_request(:post, '/1/strategies/personalization', { body: '{ "status": 200 }' })
      # get personalization strategy
      mock_request(:get, '/1/strategies/personalization', { body: '{ "eventsScoring": { } }' })
    end

    def self.mock_request(method, uri, response)
      base_uri      = '.*\.algolia(net\.com|\.net)(uri)'
      regex_uri     = uri.gsub('%s', '[^/]+')
      formatted_uri = Regexp.new base_uri.gsub('(uri)', regex_uri)
      if method == :get
        ::WebMock.stub_request(method, formatted_uri).to_return(response)
      else
        ::WebMock.stub_request(method, formatted_uri).with(body: /(.)+$/).to_return(response)
      end
    end
  end
end

Algolia::WebMock.mock!
