require 'algoliasearch'
require 'httpx/adapters/faraday'

include CallType, RetryOutcomeType
RSpec.describe Algoliasearch::Index, type: :request do
  after do
    index.clear_objects
  end

  context 'when using the index' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:client) { Algoliasearch::Client.new(config) }
    let(:index) { client.init_index('test_ruby') }

    before do
      index.save_object!({name: 'test', age: 30}, true)
    end

    it 'make a search' do
      response = index.search('test')

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['age']).to eq(30)
    end

    it 'make a search with search params' do
      response = index.search('test', attributesToRetrieve: 'name', hitsPerPage: 20)

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['age']).to be nil
    end

    it 'make a search with search params and request options' do
      response = index.search('test', {attributesToRetrieve: 'name', hitsPerPage: 20}, 'X-Forwarded-For': '0.0.0.0')

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['age']).to be nil
    end
  end

  context 'when using a custom adapter' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:client) { Algoliasearch::Client.new(config, http_requester: Algoliasearch::Http::HttpRequester, adapter: 'httpx') }
    let(:index) { client.init_index('test_ruby') }

    it 'make a search' do
      response = index.search('test')

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['age']).to eq(30)
    end
  end

  context 'when using a mock requester' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:client) { Algoliasearch::Client.new(config, http_requester: MockRequester) }
    let(:index) { client.init_index('test_ruby') }

    it 'make a search' do
      response = index.search('test')

      expect(response['hits']).not_to be nil
    end
  end
end
