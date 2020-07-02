require 'httpclient'
require_relative 'base_test'

class SearchIndexTest < BaseTest
  describe 'pass request options' do
    def before_all
      super
      @index = @@search_client.init_index(get_test_index_name('options'))
    end

    def test_with_wrong_credentials
      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.save_object(generate_object('111'), {
          headers: {
            'X-Algolia-Application-Id' => 'XXXXX',
            'X-Algolia-API-Key' => 'XXXXX'
          }
        })
      end

      assert_equal 'Invalid Application-ID or API key', exception.message
    end
  end

  describe 'save objects' do
    def before_all
      super
      @index = @@search_client.init_index(get_test_index_name('indexing'))
    end

    def retrieve_last_object_ids(responses)
      responses[-1][:objectIDs]
    end

    def test_save_objects
      responses  = []
      object_ids = []

      obj1     = generate_object('obj1')
      responses.push(@index.save_object(obj1))
      object_ids.push(retrieve_last_object_ids(responses))
      obj2     = generate_object
      response = @index.save_object(obj2, { auto_generate_object_id_if_not_exist: true })
      responses.push(response)
      object_ids.push(retrieve_last_object_ids(responses))
      responses.push(@index.save_objects([]))
      object_ids.push(retrieve_last_object_ids(responses))
      obj3     = generate_object('obj3')
      obj4     = generate_object('obj4')
      responses.push(@index.save_objects([obj3, obj4]))
      object_ids.push(retrieve_last_object_ids(responses))
      obj5     = generate_object
      obj6     = generate_object
      responses.push(@index.save_objects([obj5, obj6], { auto_generate_object_id_if_not_exist: true }))
      object_ids.push(retrieve_last_object_ids(responses))
      object_ids.flatten!
      objects  = 1.upto(1000).map do |i|
        generate_object(i.to_s)
      end

      @index.config.batch_size = 100
      responses.push(@index.save_objects(objects))
      responses.each do |res|
        task_id = get_option(res, 'taskID')
        @index.wait_task(task_id)
      end

      assert_equal obj1[:property], @index.get_object(object_ids[0])[:property]
      assert_equal obj2[:property], @index.get_object(object_ids[1])[:property]
      assert_equal obj3[:property], @index.get_object(object_ids[2])[:property]
      assert_equal obj4[:property], @index.get_object(object_ids[3])[:property]
      assert_equal obj5[:property], @index.get_object(object_ids[4])[:property]
      assert_equal obj6[:property], @index.get_object(object_ids[5])[:property]

      results = @index.get_objects((1..1000).to_a)[:results]

      results.each do |obj|
        assert_includes(objects, obj)
      end

      assert_equal objects.length, results.length
      browsed_objects = []
      @index.browse_objects do |hit|
        browsed_objects.push(hit)
      end

      assert_equal 1006, browsed_objects.length
      objects.each do |obj|
        assert_includes(browsed_objects, obj)
      end

      [obj1, obj3, obj4].each do |obj|
        assert_includes(browsed_objects, obj)
      end

      responses = []

      obj1[:property] = 'new property'
      responses.push(@index.partial_update_object(obj1))

      obj3[:property] = 'new property 3'
      obj4[:property] = 'new property 4'
      responses.push(@index.partial_update_objects([obj3, obj4]))

      responses.each do |res|
        task_id = get_option(res, 'taskID')
        @index.wait_task(task_id)
      end

      assert_equal obj1[:property], @index.get_object(object_ids[0])[:property]
      assert_equal obj3[:property], @index.get_object(object_ids[2])[:property]
      assert_equal obj4[:property], @index.get_object(object_ids[3])[:property]

      delete_by_obj = { objectID: 'obj_del_by', _tags: 'algolia', property: 'property' }
      @index.save_object!(delete_by_obj)

      responses = []

      responses.push(@index.delete_object(object_ids.shift))
      responses.push(@index.delete_by({ tagFilters: ['algolia'] }))
      responses.push(@index.delete_objects(object_ids))
      responses.push(@index.clear_objects)

      responses.each do |res|
        task_id = get_option(res, 'taskID')
        @index.wait_task(task_id)
      end

      browsed_objects = []
      @index.browse_objects do |hit|
        browsed_objects.push(hit)
      end

      assert_equal 0, browsed_objects.length
    end

    def test_save_object_without_object_id_and_fail
      exception = assert_raises Algolia::AlgoliaError do
        @index.save_object(generate_object)
      end

      assert_equal "Missing 'objectID'", exception.message
    end

    def test_save_objects_with_single_object_and_fail
      exception = assert_raises Algolia::AlgoliaError do
        @index.save_objects(generate_object)
      end

      assert_equal 'argument must be an array of objects', exception.message
    end

    def test_save_objects_with_array_of_integers_and_fail
      exception = assert_raises Algolia::AlgoliaError do
        @index.save_objects([2222, 3333])
      end

      assert_equal 'argument must be an array of object, got: 2222', exception.message
    end

    def test_save_objects_with_empty_array
      response = @index.save_objects([])

      refute_nil response[:taskID]
    end
  end

  describe 'settings' do
    def before_all
      super
      @index_name = get_test_index_name('settings')
      @index      = @@search_client.init_index(@index_name)
    end

    def test_settings
      @index.save_object!(generate_object('obj1'))

      settings = {
        searchableAttributes: %w(attribute1 attribute2 attribute3 ordered(attribute4) unordered(attribute5)),
        attributesForFaceting: %w(attribute1 filterOnly(attribute2) searchable(attribute3)),
        unretrievableAttributes: %w(
          attribute1
          attribute2
        ),
        attributesToRetrieve: %w(
          attribute3
          attribute4
        ),
        ranking: %w(asc(attribute1) desc(attribute2) attribute custom exact filters geo proximity typo words),
        customRanking: %w(asc(attribute1) desc(attribute1)),
        replicas: [
          @index_name + '_replica1',
          @index_name + '_replica2'
        ],
        maxValuesPerFacet: 100,
        sortFacetValuesBy: 'count',
        attributesToHighlight: %w(
          attribute1
          attribute2
        ),
        attributesToSnippet: %w(attribute1:10 attribute2:8),
        highlightPreTag: '<strong>',
        highlightPostTag: '</strong>',
        snippetEllipsisText: ' and so on.',
        restrictHighlightAndSnippetArrays: true,
        hitsPerPage: 42,
        paginationLimitedTo: 43,
        minWordSizefor1Typo: 2,
        minWordSizefor2Typos: 6,
        typoTolerance: 'false',
        allowTyposOnNumericTokens: false,
        ignorePlurals: true,
        disableTypoToleranceOnAttributes: %w(
          attribute1
          attribute2
        ),
        disableTypoToleranceOnWords: %w(
          word1
          word2
        ),
        separatorsToIndex: '()[]',
        queryType: 'prefixNone',
        removeWordsIfNoResults: 'allOptional',
        advancedSyntax: true,
        optionalWords: %w(
          word1
          word2
        ),
        removeStopWords: true,
        disablePrefixOnAttributes: %w(
          attribute1
          attribute2
        ),
        disableExactOnAttributes: %w(
          attribute1
          attribute2
        ),
        exactOnSingleWordQuery: 'word',
        enableRules: false,
        numericAttributesForFiltering: %w(
          attribute1
          attribute2
        ),
        allowCompressionOfIntegerArray: true,
        attributeForDistinct: 'attribute1',
        distinct: 2,
        replaceSynonymsInHighlight: false,
        minProximity: 7,
        responseFields: %w(
          hits
          hitsPerPage
        ),
        maxFacetHits: 100,
        camelCaseAttributes: %w(
          attribute1
          attribute2
        ),
        decompoundedAttributes: {
          de: %w(attribute1 attribute2),
          fi: ['attribute3']
        },
        keepDiacriticsOnCharacters: 'øé',
        queryLanguages: %w(
          en
          fr
        ),
        alternativesAsExact: ['ignorePlurals'],
        advancedSyntaxFeatures: ['exactPhrase'],
        userData: {
          customUserData: 42.0
        },
        indexLanguages: ['ja']
      }

      @index.set_settings!(settings)

      # Because the response settings dict contains the extra version key, we
      # also add it to the expected settings dict to prevent the test to fail
      # for a missing key.
      settings[:version] = 2

      assert_equal @index.get_settings, settings

      settings[:typoTolerance]   = 'min'
      settings[:ignorePlurals]   = %w(en fr)
      settings[:removeStopWords] = %w(en fr)
      settings[:distinct]        = true

      @index.set_settings!(settings)

      assert_equal @index.get_settings, settings
    end
  end

  describe 'search' do
    def before_all
      super
      @index = @@search_client.init_index(get_test_index_name('search'))
      @index.save_objects!(create_employee_records, { auto_generate_object_id_if_not_exist: true })
      @index.set_settings!(attributesForFaceting: ['searchable(company)'])
    end

    def test_search_objects
      response = @index.search('algolia')

      assert_equal 2, response[:nbHits]
      assert_equal 0, Algolia::Search::Index.get_object_position(response, 'nicolas-dessaigne')
      assert_equal 1, Algolia::Search::Index.get_object_position(response, 'julien-lemoine')
      assert_equal(-1, Algolia::Search::Index.get_object_position(response, ''))
    end

    def test_find_objects
      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({ query: '', paginate: false })
      end

      assert_equal 'Object not found', exception.message

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({ query: '', paginate: false }) { false }
      end

      assert_equal 'Object not found', exception.message

      response = @index.find_object({ query: '', paginate: false }) { true }
      assert_equal 0, response[:position]
      assert_equal 0, response[:page]

      # we use a lambda and convert it to a block with `&`
      # so as not to repeat the condition
      condition = -> (obj) do
        obj.has_key?(:company) && obj[:company] == 'Apple'
      end

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({ query: 'algolia', paginate: false }, &condition)
      end

      assert_equal 'Object not found', exception.message

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({ query: '', paginate: false, hitsPerPage: 5 }, &condition)
      end

      assert_equal 'Object not found', exception.message

      response = @index.find_object({ query: '', paginate: true, hitsPerPage: 5 }, &condition)
      assert_equal 0, response[:position]
      assert_equal 2, response[:page]

      response = @index.search('elon', { clickAnalytics: true })

      refute_nil response[:queryID]

      response = @index.search('elon', { facets: '*', facetFilters: ['company:tesla'] })

      assert_equal 1, response[:nbHits]

      response = @index.search('elon', { facets: '*', filters: '(company:tesla OR company:spacex)' })

      assert_equal 2, response[:nbHits]

      response = @index.search_for_facet_values('company', 'a')

      assert(response[:facetHits].any? { |hit| hit[:value] == 'Algolia' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Amazon' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Apple' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Arista Networks' })
    end
  end
end
