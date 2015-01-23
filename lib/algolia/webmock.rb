begin
  require 'webmock'
rescue LoadError
  puts 'WebMock was not found, please add "gem \'webmock\'" to your Gemfile.'
  exit 1
end

ALGOLIA_WEBMOCKS = {
  # list indexes
  [:get, %r{/1/indexes/}] => '{ "items": [] }',
  # query index
  [:get, %r{/1/indexes/[^/]+}] => '{}',
  [:post, %r{/1/indexes/[^/]+/query}] => '{}',
  # delete index
  [:delete, %r{/1/indexes/[^/]+}] => '{ "taskID": 42 }',
  # clear index
  [:post, %r{/1/indexes/[^/]+/clear}] => '{ "taskID": 42 }',
  # add object
  [:post, %r{/1/indexes/[^/]+}] => '{ "taskID": 42 }',
  # save object
  [:put, %r{/1/indexes/[^/]+/[^/]+}] => '{ "taskID": 42 }',
  # partial update
  [:put, %r{/1/indexes/[^/]+/[^/]+/partial}] => '{ "taskID": 42 }',
  # get object
  [:get, %r{/1/indexes/[^/]+/[^/]+}] => '{}',
  # delete object
  [:delete, %r{/1/indexes/[^/]+/[^/]+}] => '{ "taskID": 42 }',
  # batch
  [:post, %r{/1/indexes/[^/]+/batch}] => '{ "taskID": 42 }',
  # settings
  [:get, %r{/1/indexes/[^/]+/settings}] => '{}',
  [:put, %r{/1/indexes/[^/]+/settings}] => '{ "taskID": 42 }',
  # browse
  [:get, %r{/1/indexes/[^/]+/browse}] => '{}',
  # operations
  [:post, %r{/1/indexes/[^/]+/operation}] => '{ "taskID": 42 }',
  # tasks
  [:get, %r{/1/indexes/[^/]+/task/[^/]+}] => '{ "status": "published" }',
  # index keys
  [:post, %r{/1/indexes/[^/]+/keys}] => '{ }',
  [:get, %r{/1/indexes/[^/]+/keys}] => '{ "keys": [] }',
  # global keys
  [:post, %r{/1/keys}] => '{ }',
  [:get, %r{/1/keys}] => '{ "keys": [] }',
  [:get, %r{/1/keys/[^/]+}] => '{ }',
  [:delete, %r{/1/keys/[^/]+}] => '{ }',
}

module Algolia
  def self.load_webmocks!
    WebMock.stub_request(:any, /.*\.algolia\.(io|net)/).to_return do |request|
      match = ALGOLIA_WEBMOCKS.find do |pattern, retval|
        request.method == pattern[0] && pattern[1].match(request.uri.path)
      end

      if match
        { body: match[1] }
      else
        raise format('Un-mocked Algolia request in WebMock mode: %s %s',
                     request.method.upcase, request.uri)
      end
    end
  end
end
