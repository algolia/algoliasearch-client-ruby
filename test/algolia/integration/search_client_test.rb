require_relative 'base_test'

class SearchClientTest < BaseTest
  describe 'customize search client' do
    def test_with_custom_adapter
      client = Algolia::Search::Client.new(@@search_config, adapter: 'httpclient')
      index  = client.init_index(get_test_index_name('test_custom_adapter'))

      index.save_object!({ name: 'test', data: 10 }, { auto_generate_object_id_if_not_exist: true })
      response = index.search('test')

      refute_empty response[:hits]
      assert_equal 'test', response[:hits][0][:name]
      assert_equal 10, response[:hits][0][:data]
    end

    def test_with_custom_requester
      client = Algolia::Search::Client.new(@@search_config, http_requester: MockRequester.new)
      index  = client.init_index(get_test_index_name('test_custom_requester'))

      response = index.search('test')

      refute_nil response[:hits]
    end

    def test_without_providing_config
      client   = Algolia::Search::Client.create(APPLICATION_ID_1, ADMIN_KEY_1)
      index    = client.init_index(get_test_index_name('test_no_config'))
      index.save_object!({ name: 'test', data: 10 }, { auto_generate_object_id_if_not_exist: true })
      response = index.search('test')

      refute_empty response[:hits]
      assert_equal 'test', response[:hits][0][:name]
      assert_equal 10, response[:hits][0][:data]
    end
  end
end
