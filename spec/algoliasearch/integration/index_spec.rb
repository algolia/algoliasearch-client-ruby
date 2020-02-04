require 'algoliasearch'
require 'httpx/adapters/faraday'

include CallType, RetryOutcomeType
RSpec.describe Algolia::Search::Index, type: :request do
  let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
  let(:api_key) { ENV['ALGOLIA_API_KEY'] }
  let(:config) { Algolia::Search::Config.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
  let(:client) { Algolia::Search::Client.new(config) }
  let(:index) { client.init_index('test_ruby') }

  context 'with save_object(s)' do
    after do
      index.clear_objects
    end

    it 'create an index with an invalid name' do
      expect do
        client.init_index('   ')
      end.to raise_error(ArgumentError, 'Please provide a valid index name')
    end

    it 'save an object' do
      object   = {name: 'test two', data: 20, objectID: '222'}
      response = index.save_object(object)

      expect(response['objectIDs']).to eq(['222'])
      expect(response['taskID']).not_to be nil
    end

    it 'save an object without object ID' do
      object   = {name: 'test two', data: 20}
      response = index.save_object(object, auto_generate_object_id_if_not_exist: true)

      expect(response['objectIDs']).not_to be_empty
      expect(response['taskID']).not_to be nil
    end

    it 'save an object without object ID without setting autoGenerateObjectIDIfNotExist' do
      object = {name: 'test two', data: 20}
      expect do
        index.save_object(object)
      end.to raise_error(ArgumentError, "Missing 'objectID'")
    end

    it 'save an object and wait for the engine' do
      object = {name: 'newtest two', data: 20, objectID: '222'}
      index.save_object!(object)

      response = index.search('newtest')
      expect(response['hits']).not_to be_empty
    end

    it 'save an object with request options' do
      object   = {name: 'test two', data: 20, objectID: '222'}
      response = index.save_object(object, auto_generate_object_id_if_not_exist: false, opts: {headers: {'X-Forwarded-For': '0.0.0.0'}})

      expect(response['objectIDs']).to eq(['222'])
      expect(response['taskID']).not_to be nil
    end

    it 'save an array of object' do
      objects = [
        {name: 'test two', data: 20, objectID: '222'},
        {name: 'test three', data: 30, objectID: '333'}
      ]

      response = index.save_objects(objects)

      expect(response['objectIDs']).to eq(%w(222 333))
      expect(response['taskID']).not_to be nil
    end

    it 'save a simple object instead of an array' do
      object = {name: 'test two', data: 20, objectID: '222'}

      expect do
        index.save_objects(object)
      end.to raise_error(ArgumentError, 'argument must be an array of objects')
    end

    it 'save an array of integer instead of objects' do
      objects = [2222, 3333]

      expect do
        index.save_objects(objects)
      end.to raise_error(ArgumentError, 'argument must be an array of object, got: 2222')
    end

    it 'save an array of object and wait for the engine' do
      objects = [
        {name: 'test two', data: 20, objectID: '222'},
        {name: 'test four', data: 40, objectID: '4444'}
      ]

      index.save_objects!(objects, auto_generate_object_id_if_not_exist: true, opts: {headers: {'Test': 'test'}})

      response = index.search('four')
      expect(response['hits']).not_to be_empty
    end
  end

  context 'with search' do
    after do
      index.clear_objects
    end

    before do
      index.save_object!({name: 'test', data: 10}, auto_generate_object_id_if_not_exist: true)
    end

    it 'make a search' do
      response = index.search('test')

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['data']).to eq(10)
    end

    it 'make a search with unknown search parameters' do
      expect do
        index.search('test', search_params: {myCustomParam: 20})
      end.to raise_error(Algolia::AlgoliaApiError, 'Unknown parameter: myCustomParam')
    end

    it 'make a search with unknown request options' do
      response = index.search('test', search_params: {hitsPerPage: 20}, opts: {headers: {'Custom-Header': 'XX-XX'}})

      expect(response['hits']).not_to be_empty
    end

    it 'make a search with search params' do
      response = index.search('test', search_params: {attributesToRetrieve: 'name', hitsPerPage: 20})

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['data']).to be nil
    end

    it 'make a search with search params and request options' do
      response = index.search('test', search_params: {attributesToRetrieve: 'name', hitsPerPage: 20}, opts: {headers: {'X-Forwarded-For': '0.0.0.0'}})

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['data']).to be nil
    end
  end

  context 'with clear_objects' do
    it 'clears all objects and wait for the engine' do
      index.save_object!({name: 'test', data: 10}, auto_generate_object_id_if_not_exist: true)

      response = index.search('test')
      expect(response['nbHits']).to eq(1)

      index.clear_objects!

      response = index.search('test')
      expect(response['nbHits']).to eq(0)
    end
  end

  context 'when using a custom adapter' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algolia::Search::Config.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:client) { Algolia::Search::Client.new(config, http_requester: Algolia::Http::HttpRequester, adapter: 'httpx') }
    let(:index) { client.init_index('test_ruby') }

    it 'make a search' do
      index.save_object!({name: 'test', data: 10}, auto_generate_object_id_if_not_exist: true)
      response = index.search('test')

      expect(response['hits']).not_to be_empty
      expect(response['hits'][0]['name']).to eq('test')
      expect(response['hits'][0]['data']).to eq(10)
      index.clear_objects!
    end
  end

  context 'when using a mock requester' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algolia::Search::Config.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:client) { Algolia::Search::Client.new(config, http_requester: MockRequester) }
    let(:index) { client.init_index('test_ruby') }

    it 'make a search' do
      response = index.search('test')

      expect(response['hits']).not_to be nil
    end
  end
end
