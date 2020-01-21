require 'algoliasearch'

include CallType, RetryOutcomeType
RSpec.describe Algoliasearch::Transport::RetryStrategy, type: :unit do
  shared_examples 'Reset' do |call_type, timeout|
    context 'when it resets expired hosts' do
      let(:app_id) { ENV['ALGOLIA_APPLICATION_ID'] }
      let(:api_key) { ENV['ALGOLIA_ADMIN_KEY'] }
      let(:config) { Algoliasearch::SearchConfig.new(app_id, api_key) }

      it 'resets expired hosts according to call_type' do
        stateful_hosts = []
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-4.algolianet.com")
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-5.algolianet.com", up: false)
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-6.algolianet.com")

        config.custom_hosts = stateful_hosts
        retry_strategy = described_class.new(config)

        hosts = retry_strategy.get_tryable_hosts(call_type)
        expect(hosts.length).to be 2
      end

      it 'resets expired hosts according to call_type and timeout' do
        stateful_hosts = []
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-4.algolianet.com")
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-5.algolianet.com", up: false, last_use: Time.new.utc - timeout)
        stateful_hosts << Algoliasearch::Transport::StatefulHost.new("#{app_id}-6.algolianet.com")

        config.custom_hosts = stateful_hosts
        retry_strategy = described_class.new(config)

        hosts = retry_strategy.get_tryable_hosts(call_type)
        expect(hosts.length).to be 3
      end
    end
  end

  describe 'Reset hosts for READ' do
    include_examples 'Reset', READ, 1000
  end

  describe 'Reset hosts for WRITE' do
    include_examples 'Reset', WRITE, 1000
  end

  shared_examples 'Decide' do |call_type, http_response_code, is_timed_out, retry_outcome_code, hosts_length|
    let(:config) { Algoliasearch::SearchConfig.new('app_id', 'api_key') }

    it "tests response for call type #{call_type} and HTTP code #{http_response_code}" do
      retry_strategy = described_class.new(config)

      hosts = retry_strategy.get_tryable_hosts(call_type)
      expect(hosts.length).to be 4

      decision = retry_strategy.decide(hosts.first, http_response_code, is_timed_out)
      expect(decision).to be retry_outcome_code

      hosts = retry_strategy.get_tryable_hosts(call_type)
      expect(hosts.length).to be hosts_length
    end
  end

  describe 'Decides to retry on 30*/50*' do
    include_examples 'Decide', READ, 500, false, RETRY, 3
    include_examples 'Decide', WRITE, 500, false, RETRY, 3
    include_examples 'Decide', READ, 300, false, RETRY, 3
    include_examples 'Decide', WRITE, 300, false, RETRY, 3
  end

  describe 'Decides to retry on timeout' do
    include_examples 'Decide', READ, 500, true, RETRY, 4
    include_examples 'Decide', READ, 300, true, RETRY, 4
    include_examples 'Decide', WRITE, 500, true, RETRY, 4
    include_examples 'Decide', WRITE, 500, true, RETRY, 4
  end

  describe 'Decides to fail on 40*' do
    include_examples 'Decide', READ, 400, false, FAILURE, 4
    include_examples 'Decide', READ, 400, false, FAILURE, 4
    include_examples 'Decide', READ, 404, false, FAILURE, 4
    include_examples 'Decide', READ, 404, false, FAILURE, 4
  end

  describe 'Decides to succeed on 200' do
    include_examples 'Decide', READ, 200, false, SUCCESS, 4
    include_examples 'Decide', READ, 200, false, SUCCESS, 4
  end
end
