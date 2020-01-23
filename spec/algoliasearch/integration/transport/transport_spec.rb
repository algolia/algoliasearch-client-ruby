require 'algoliasearch'

include CallType, RetryOutcomeType
RSpec.describe Algoliasearch::Transport::Transport, type: :request do
  context 'when using the transport layer' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id: app_id, api_key: api_key, user_agent: 'test-ruby') }
    let(:transport) { described_class.new(config) }

    it 'request succeeds' do
      response = transport.request(READ, :GET, Algoliasearch::Http::Protocol.indexes_uri)

      expect(response.body['items']).not_to be nil
    end

    it 'request fails with wrong credentials' do
      custom_headers = {
        Defaults::HEADER_API_KEY => 'xxxxxxx',
        Defaults::HEADER_APP_ID => 'XXXX'
      }

      expect do
        transport.request(READ, :GET, Algoliasearch::Http::Protocol.indexes_uri, {}, headers: custom_headers)
      end.to raise_error(Algoliasearch::AlgoliaApiError)
    end
  end
end
