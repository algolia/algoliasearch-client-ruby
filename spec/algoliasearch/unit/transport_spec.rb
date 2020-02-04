require 'algoliasearch'

include CallType, RetryOutcomeType
RSpec.describe Algolia::Transport::Transport, type: :unit do
  context 'when sending requests through the transport layer' do
    let(:app_id) { 'app_id' }
    let(:api_key) { 'api_key' }
    let(:config) do
      Algolia::Search::Config.new(app_id: app_id, api_key: api_key, custom_hosts:
        [
          Algolia::Transport::StatefulHost.new("#{app_id}-4.algolianet.com"),
          Algolia::Transport::StatefulHost.new("#{app_id}-5.algolianet.com")
        ])
    end
    let(:transport) { described_class.new(config) }
    let(:indexes_uri) { "/#{Defaults::VERSION}/indexes" }

    it 'receives 400 and stops' do
      stub_request(:any, "https://#{app_id}-4.algolianet.com" + indexes_uri)
        .to_return(body: '{}', status: 400, headers: {'Content-Length' => 3})

      expect do
        transport.read(:GET, indexes_uri)
      end.to raise_error(Algolia::AlgoliaApiError)
    end

    it 'receives 500 and tries next host' do
      stub_request(:any, "https://#{app_id}-4.algolianet.com" + indexes_uri)
        .to_return(body: '{}', status: 500, headers: {'Content-Length' => 3})

      stub_request(:any, "https://#{app_id}-5.algolianet.com" + indexes_uri)
        .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = transport.read(:GET, indexes_uri)
      expect(response['items']).to eq('abc')
      expect(config.default_hosts.first.retry_count).to eq(0)
    end

    it 'times out and tries next host' do
      stub_request(:any, "https://#{app_id}-4.algolianet.com" + indexes_uri)
        .to_raise(Faraday::TimeoutError)

      stub_request(:any, "https://#{app_id}-5.algolianet.com" + indexes_uri)
        .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = transport.read(:GET, indexes_uri)
      expect(response['items']).to eq('abc')
      expect(config.default_hosts.first.retry_count).to eq(1)
    end

    it 'succeeds and stops' do
      stub_request(:any, "https://#{app_id}-4.algolianet.com" + indexes_uri)
        .to_return(body: '{"items": "def"}', status: 200, headers: {'Content-Length' => 3})

      stub_request(:any, "https://#{app_id}-5.algolianet.com" + indexes_uri)
        .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = transport.read(:GET, indexes_uri)
      expect(response['items']).to eq('def')
      expect(config.default_hosts.first.retry_count).to eq(0)
    end
  end
end
