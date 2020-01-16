require 'algoliasearch'

include CallType, RetryOutcomeType
RSpec.describe Algoliasearch::Transport::Transport, type: :request do
  context 'when using the transport layer' do
    let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
    let(:api_key) { ENV['ALGOLIA_API_KEY'] }
    let(:config) { Algoliasearch::SearchConfig.new(app_id, api_key, user_agent: 'test-ruby') }
    let(:transport) { described_class.new(config) }

    it 'request succeeds' do
      response = transport.request(READ, :GET, Algoliasearch::Http::Protocol.indexes_uri)

      expect(response.body['items']).not_to be nil
    end

    it 'request fails with wrong credentials' do
      custom_headers = {
        Algoliasearch::Http::Protocol::HEADER_API_KEY => 'xxxxxxx',
        Algoliasearch::Http::Protocol::HEADER_APP_ID  => 'XXXX'
      }
      response = transport.request(READ, :GET, Algoliasearch::Http::Protocol.indexes_uri, {}, {}, headers: custom_headers)

      expect(response.error['message']).to eq('Invalid Application-ID or API key')
      expect(response.status).to eq(403)
    end
  end
end
