require 'algolia/webmock'
require_relative 'base_test'

class WebmockTest < BaseTest
  describe 'test algolia webmock' do
    def before_all
      super
      WebMock.enable!
      Algolia::WebMock.mock!
    end

    def test_webmock
      index = @@search_client.init_index(get_test_index_name('webmock'))
      index.save_object!({ name: 'John Doe', email: 'john@doe.org', objectID: 'one' })
      assert_equal index.search(''), { hits: [{ objectID: 42 }], page: 1, hitsPerPage: 1, nbHits: 1, nbPages: 1 }
      assert_equal @@search_client.list_indexes, { items: [] }
      index.get_settings
      index.clear_objects
      index.delete
    end

    def after_all
      WebMock.disable!
      super
    end
  end
end
