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

      id1     = 'obj1'
      obj1    = generate_object(id1)
      responses.push(@index.save_object(obj1))
      object_ids.push(retrieve_last_object_ids(responses))
      obj2    = generate_object
      responses.push(@index.save_object(obj2, {auto_generate_object_id_if_not_exist: true}))
      object_ids.push(retrieve_last_object_ids(responses))
      responses.push(@index.save_objects([]))
      object_ids.push(retrieve_last_object_ids(responses))
      id3     = 'obj3'
      id4     = 'obj4'
      obj3    = generate_object(id3)
      obj4    = generate_object(id4)
      responses.push(@index.save_objects([obj3, obj4]))
      object_ids.push(retrieve_last_object_ids(responses))
      obj5    = generate_object
      obj6    = generate_object
      responses.push(@index.save_objects([obj5, obj6], {auto_generate_object_id_if_not_exist: true}))
      object_ids.push(retrieve_last_object_ids(responses))
      object_ids.flatten!
      objects = 1.upto(1000).map do |i|
        generate_object(i.to_s)
      end

      @index.config.batch_size = 100
      responses.push(@index.save_objects(objects))
      responses.each do |response|
        task_id = get_option(response, 'taskID')
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
      @index.browse_objects.each do |hit|
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

      responses.each do |response|
        task_id = get_option(response, 'taskID')
        @index.wait_task(task_id)
      end

      assert_equal obj1[:property], @index.get_object(id1)[:property]
      assert_equal obj3[:property], @index.get_object(id3)[:property]
      assert_equal obj4[:property], @index.get_object(id4)[:property]
    end

    def test_save_object_without_object_id_and_fail
      exception = assert_raises ArgumentError do
        @index.save_object(generate_object)
      end

      assert_equal "Missing 'objectID'", exception.message
    end

    def test_save_objects_with_single_object_and_fail
      exception = assert_raises ArgumentError do
        @index.save_objects(generate_object)
      end

      assert_equal 'argument must be an array of objects', exception.message
    end

    def test_save_objects_with_array_of_integers_and_fail
      exception = assert_raises ArgumentError do
        @index.save_objects([2222, 3333])
      end

      assert_equal 'argument must be an array of object, got: 2222', exception.message
    end

    def test_save_objects_with_empty_array
      response = @index.save_objects([])

      refute_nil response[:taskID]
    end

    def test_batch_save_objects
      ids     = []
      objects = []
      1.upto(8).map do |i|
        id = (i + 1).to_s
        objects << generate_object(id)
        ids << id
      end

      batch = @index.save_objects(objects)
      @index.wait_task(batch[:taskID])
    end
  end

  describe 'search' do
    def before_all
      super
      @index = @@search_client.init_index(get_test_index_name('search'))
      @index.save_objects!(create_employee_records, {auto_generate_object_id_if_not_exist: true})
      @index.set_settings!(attributesForFaceting: ['searchable(company)'])
    end

    def test_search_objects
      response = @index.search('algolia')

      assert_equal 2, response[:nbHits]
      assert_equal 0, Algolia::Search::Index.get_object_position(response, 'nicolas-dessaigne')
      assert_equal 1, Algolia::Search::Index.get_object_position(response, 'julien-lemoine')
      assert_equal(-1, Algolia::Search::Index.get_object_position(response, ''))
    end

    def find_objects
      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({query: '', paginate: false})
      end

      assert_equal 'Object not found', exception.message

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({query: '', paginate: false}) { false }
      end

      assert_equal 'Object not found', exception.message

      response = @index.find_object({query: '', paginate: false}) { true }
      assert_equal 0, response[:position]
      assert_equal 0, response[:page]

      # we use a lambda and convert it to a block with `&`
      # so as not to repeat the condition
      condition = -> (obj) do
        obj.has_key?('company') && obj['company'] == 'Apple'
      end

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({query: 'algolia', paginate: false}, &condition)
      end

      assert_equal 'Object not found', exception.message

      exception = assert_raises Algolia::AlgoliaHttpError do
        @index.find_object({query: '', paginate: false, hitsPerPage: 5}, &condition)
      end

      assert_equal 'Object not found', exception.message

      response = @index.find_object({query: '', paginate: true, hitsPerPage: 5}, &condition)
      assert_equal 0, response[:position]
      assert_equal 2, response[:page]
    end

    def test_search_with_click_analytics
      response = @index.search('elon', {clickAnalytics: true})

      refute_nil response[:queryID]
    end

    def test_search_with_facet_filters
      response = @index.search('elon', {facets: '*', facetFilters: ['company:tesla']})

      assert_equal 1, response[:nbHits]
    end

    def test_search_with_filter
      response = @index.search('elon', {facets: '*', filters: '(company:tesla OR company:spacex)'})

      assert_equal 2, response[:nbHits]
    end

    def test_search_for_facet_values
      response = @index.search_for_facet_values('company', 'a')

      assert(response[:facetHits].any? { |hit| hit[:value] == 'Algolia' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Amazon' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Apple' })
      assert(response[:facetHits].any? { |hit| hit[:value] == 'Arista Networks' })
    end
  end
end
