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

  describe 'copy index' do
    def before_all
      super
      @index_name = get_test_index_name('copy_index')
      @index      = @@search_client.init_index(@index_name)
    end

    def test_copy_index
      responses = []

      objects = [
        { objectID: 'one', company: 'apple' },
        { objectID: 'two', company: 'algolia' }
      ]
      responses.push(@index.save_objects(objects))

      settings = { attributesForFaceting: ['company'] }
      responses.push(@index.set_settings(settings))

      synonym = {
        objectID: 'google_placeholder',
        type: 'placeholder',
        placeholder: '<GOOG>',
        replacements: %w(Google GOOG)
      }
      responses.push(@index.save_synonym(synonym))

      rule = {
        objectID: 'company_auto_faceting',
        condition: {
          anchoring: 'contains',
          pattern: '{facet:company}'
        },
        consequence: {
          params: { automaticFacetFilters: ['company'] }
        }
      }
      responses.push(@index.save_rule(rule))

      responses.each do |res|
        task_id = get_option(res, 'taskID')
        @index.wait_task(task_id)
      end

      copy_settings_index  = @@search_client.init_index(get_test_index_name('copy_index_settings'))
      copy_rules_index     = @@search_client.init_index(get_test_index_name('copy_index_rules'))
      copy_synonyms_index  = @@search_client.init_index(get_test_index_name('copy_index_synonyms'))
      copy_full_copy_index = @@search_client.init_index(get_test_index_name('copy_index_full_copy'))
      @@search_client.copy_settings!(@index_name, copy_settings_index.index_name)
      @@search_client.copy_rules!(@index_name, copy_rules_index.index_name)
      @@search_client.copy_synonyms!(@index_name, copy_synonyms_index.index_name)
      @@search_client.copy_index!(@index_name, copy_full_copy_index.index_name)

      assert_equal @index.get_settings, copy_settings_index.get_settings
      assert_equal @index.get_rule(rule[:objectID]), copy_rules_index.get_rule(rule[:objectID])
      assert_equal @index.get_synonym(synonym[:objectID]), copy_settings_index.get_synonym(synonym[:objectID])
      assert_equal @index.get_settings, copy_full_copy_index.get_settings
      assert_equal @index.get_rule(rule[:objectID]), copy_full_copy_index.get_rule(rule[:objectID])
      assert_equal @index.get_synonym(synonym[:objectID]), copy_full_copy_index.get_synonym(synonym[:objectID])
    end
  end
end
