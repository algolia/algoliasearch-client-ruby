require 'algolia'
require 'webmock/minitest'
require 'test_helper'

class TransportTest
  include RetryOutcomeType
  include CallType
  describe 'using the transport layer' do
    def before_all
      super
      @app_id  = 'app_id'
      @api_key = 'api_key'
      @config  = Algolia::Search::Config.new(app_id: @app_id, api_key: @api_key, custom_hosts:
        [
          Algolia::Transport::StatefulHost.new("#{@app_id}-4.algolianet.com"),
          Algolia::Transport::StatefulHost.new("#{@app_id}-5.algolianet.com")
        ])
      @transport   = Algolia::Transport::Transport.new(@config)
      @indexes_uri = "/#{Defaults::VERSION}/indexes"
    end

    def test_receives_400_and_stops
      stub_request(:any, "https://#{@app_id}-4.algolianet.com" + @indexes_uri)
        .to_return(body: '{}', status: 400, headers: {'Content-Length' => 3})

      exception = assert_raises Algolia::AlgoliaApiError do
        @transport.read(:GET, @indexes_uri)
      end

      assert_equal 400, exception.code
    end

    def test_receives_500_and_tries_next_host
      stub_request(:any, "https://#{@app_id}-4.algolianet.com" + @indexes_uri)
          .to_return(body: '{}', status: 500, headers: {'Content-Length' => 3})

      stub_request(:any, "https://#{@app_id}-5.algolianet.com" + @indexes_uri)
          .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = @transport.read(:GET, @indexes_uri)

      assert_equal 'abc', response['items']
      refute @config.default_hosts.first.up
    end

    def test_times_out_and_tries_next_host
      stub_request(:any, "https://#{@app_id}-4.algolianet.com" + @indexes_uri)
          .to_raise(Faraday::TimeoutError)

      stub_request(:any, "https://#{@app_id}-5.algolianet.com" + @indexes_uri)
          .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = @transport.read(:GET, @indexes_uri)

      assert_equal 'abc', response['items']
      assert_equal 1, @config.default_hosts.first.retry_count
    end

    def test_succeeds_and_stop
      stub_request(:any, "https://#{@app_id}-4.algolianet.com" + @indexes_uri)
          .to_return(body: '{"items": "def"}', status: 200, headers: {'Content-Length' => 3})

      stub_request(:any, "https://#{@app_id}-5.algolianet.com" + @indexes_uri)
          .to_return(body: '{"items": "abc"}', status: 200, headers: {'Content-Length' => 3})

      response = @transport.read(:GET, @indexes_uri)

      assert_equal 'def', response['items']
      assert_equal 0, @config.default_hosts.first.retry_count
    end
  end
end
