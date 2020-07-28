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
      responses = Algolia::MultipleResponse.new

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

      responses.wait

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

  describe 'MCM' do
    def before_all
      super
      @mcm_client = Algolia::Search::Client.create(MCM_APPLICATION_ID, MCM_ADMIN_KEY)
    end

    def test_mcm
      clusters = @mcm_client.list_clusters
      assert_equal 2, clusters[:clusters].length

      cluster_name = clusters[:clusters][0][:clusterName]

      mcm_user_id0 = get_mcm_user_name(0)
      mcm_user_id1 = get_mcm_user_name(1)
      mcm_user_id2 = get_mcm_user_name(2)

      @mcm_client.assign_user_id(mcm_user_id0, cluster_name)
      @mcm_client.assign_user_ids([mcm_user_id1, mcm_user_id2], cluster_name)

      0.upto(2) do |i|
        retrieved_user = retrieve_user_id(i)
        assert_equal(retrieved_user, {
          userID: get_mcm_user_name(i),
          clusterName: cluster_name,
          nbRecords: 0,
          dataSize: 0
        })
      end

      refute_equal 0, @mcm_client.list_user_ids[:userIDs].length
      refute_equal 0, @mcm_client.get_top_user_ids[:topUsers].length

      0.upto(2) do |i|
        remove_user_id(i)
      end

      0.upto(2) do |i|
        assert_removed(i)
      end

      has_pending_mappings = @mcm_client.pending_mappings?({ retrieveMappings: true })
      refute_nil has_pending_mappings
      assert has_pending_mappings[:pending]
      assert has_pending_mappings[:clusters]
      assert_instance_of Hash, has_pending_mappings[:clusters]

      has_pending_mappings = @mcm_client.pending_mappings?({ retrieveMappings: false })
      refute_nil has_pending_mappings
      assert has_pending_mappings[:pending]
      refute has_pending_mappings[:clusters]
    end

    def retrieve_user_id(number)
      loop do
        begin
          return @mcm_client.get_user_id(get_mcm_user_name(number))
        rescue Algolia::AlgoliaHttpError => e
          if e.code != 404
            raise StandardError
          end
        end
      end
    end

    def remove_user_id(number)
      loop do
        begin
          return @mcm_client.remove_user_id(get_mcm_user_name(number))
        rescue Algolia::AlgoliaHttpError => e
          if e.code != 400
            raise StandardError
          end
        end
      end
    end

    def assert_removed(number)
      loop do
        begin
          return @mcm_client.get_user_id(get_mcm_user_name(number))
        rescue Algolia::AlgoliaHttpError => e
          if e.code == 404
            return true
          end
        end
      end
    end
  end

  describe 'API keys' do
    def before_all
      super
      response = @@search_client.add_api_key!(['search'], {
        description: 'A description',
        indexes: ['index'],
        maxHitsPerQuery: 1000,
        maxQueriesPerIPPerHour: 1000,
        queryParameters: 'typoTolerance=strict',
        referers: ['referer'],
        validity: 600
      })
      @api_key = @@search_client.get_api_key(response.raw_response[:key])
    end

    def teardown
      @@search_client.delete_api_key!(@api_key[:value])
    end

    def test_api_keys
      assert_equal ['search'], @api_key[:acl]

      api_keys = @@search_client.list_api_keys[:keys].map do |key|
        key[:value]
      end
      assert_includes api_keys, @api_key[:value]

      @@search_client.update_api_key!(@api_key[:value], { maxHitsPerQuery: 42 })
      updated_api_key = @@search_client.get_api_key(@api_key[:value])
      assert_equal 42, updated_api_key[:maxHitsPerQuery]

      @@search_client.delete_api_key!(@api_key[:value])

      exception = assert_raises Algolia::AlgoliaHttpError do
        @@search_client.get_api_key(@api_key[:value])
      end

      assert_equal 'Key does not exist', exception.message

      @@search_client.restore_api_key!(@api_key[:value])

      restored_key = @@search_client.get_api_key(@api_key[:value])

      refute_nil restored_key
    end
  end
end
