require 'algolia'
require 'test_helper'

class SearchClientTest
    describe 'search client' do
      def before_all
        super
        @app_id          = 'app_id'
        @api_key         = 'api_key'
        @config          = Algolia::Search::Config.new(app_id: @app_id, api_key: @api_key)
        @search_client   = Algolia::Search::Client.new(@config)
        @default_headers = @config.default_headers
      end

      def test_add_headers
        @search_client.set_extra_header('admin', 'admin-key')
        assert_equal 'admin-key', @default_headers['admin']
      end
    end
end
