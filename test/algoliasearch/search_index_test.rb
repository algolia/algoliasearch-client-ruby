require "minitest/autorun"
require 'test_helper'
require_relative 'base_test'

# TODO: create algoliaStub method or other to create objects
class SearchIndexTest < BaseTest
  describe 'save objects' do
    def before_all
      super
      @index = @@search_client.init_index(get_test_index_name('indexing'))
    end

    def after_all
      @index.clear_objects
      super
    end

    def test_save_object_without_object_id_and_fail
      exception = assert_raises ArgumentError do
        @index.save_object({name: 'test save 1', data: 10})
      end

      assert_equal "Missing 'objectID'", exception.message
    end

    def test_save_object_with_object_id
      response = @index.save_object({name: 'test save 1', data: 10, objectID: '111'})

      assert_equal(response['objectIDs'], ['111'])
      assert response['taskID'] != nil
    end

    def test_save_object_with_object_id_and_auto_generate_object_id_if_not_exist
      response = @index.save_object({name: 'test save 1', data: 10, objectID: '111'}, auto_generate_object_id_if_not_exist: true)

      assert_equal(response['objectIDs'], ['111'])
      assert response['taskID'] != nil
    end

    def test_save_object_with_object_id_and_request_options
      response = @index.save_object({name: 'test save 1', data: 10, objectID: '111'}, opts: {headers: {'X-Forwarded-For': '0.0.0.0'}})

      assert_equal(response['objectIDs'], ['111'])
      assert response['taskID'] != nil
    end

    def test_save_object_without_object_id
      response = @index.save_object({name: 'test save 1', data: 10}, auto_generate_object_id_if_not_exist: true)

      refute_empty response['objectIDs']
      assert response['taskID'] != nil
    end

    def test_save_objects_with_single_object_and_fail
      exception = assert_raises ArgumentError do
        @index.save_objects({name: 'test save 1', data: 10})
      end

      assert_equal "argument must be an array of objects", exception.message
    end

    def test_save_objects_with_array_of_integers_and_fail
      exception = assert_raises ArgumentError do
        @index.save_objects([2222, 3333])
      end

      assert_equal "argument must be an array of object, got: 2222", exception.message
    end

    def test_save_objects_with_empty_array
      response = @index.save_objects([])

      assert response['taskID'] != nil
    end

    def test_save_objects_with_object_id
      response = @index.save_objects([
         {name: 'test save 1', data: 10, objectID: '111'},
         {name: 'test save 2', data: 20, objectID: '222'},
      ])

      assert_equal(response['objectIDs'], %w(111 222))
      assert response['taskID'] != nil
    end

    def test_save_objects_without_object_id
      response = @index.save_objects([
         {name: 'test save 1', data: 10},
         {name: 'test save 2', data: 20},
      ], auto_generate_object_id_if_not_exist: true)

      refute_empty response['objectIDs']
      assert response['taskID'] != nil
    end

    def test_batch_save_objects
      ids = []
      objects = []
      1.upto(8).map do |i|
        id = (i + 1).to_s
        objects << {name: "test#{id}", objectID: id}
        ids << id
      end

      batch = @index.save_objects(objects)
      @index.wait_task(batch['taskID'])
    end
  end
end
