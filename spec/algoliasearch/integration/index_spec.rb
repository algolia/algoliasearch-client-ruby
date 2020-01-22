require 'algoliasearch'

include CallType, RetryOutcomeType
RSpec.describe Algoliasearch::Index, type: :request do
  context 'when using the index' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id, api_key, user_agent: 'test-ruby') }
    let(:client) { Algoliasearch::Client.new(config) }
    let(:index) { client.init_index('test_ruby')}

    it 'make a search' do
      res = index.save_object(test: 'test')
      response = index.search('query')

      expect(response.body['hits']).not_to be nil
    end
  end
end
