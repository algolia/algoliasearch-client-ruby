require_relative '../base_test'

class TransportTest < BaseTest
  describe 'use transport layer' do
    def before_all
      super
      @transport   = Algolia::Transport::Transport.new(@@search_config)
      @indexes_uri = "/#{Defaults::VERSION}/indexes"
    end

    def test_fails_with_wrong_credentials
      custom_headers = {
        Defaults::HEADER_API_KEY => 'xxxxxxx',
        Defaults::HEADER_APP_ID => 'XXXX'
      }

      exception = assert_raises Algolia::AlgoliaHttpError do
        @transport.read(:GET, @indexes_uri, {}, {headers: custom_headers})
      end

      assert_equal 'Invalid Application-ID or API key', exception.message
    end

    def test_request_succeeds
      response = @transport.read(:GET, @indexes_uri)

      refute_nil response['items']
    end
  end
end
