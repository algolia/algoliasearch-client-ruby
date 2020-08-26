require 'algolia'
require 'test_helper'

class HelpersTest
  include Helpers
  describe 'test helpers' do
    def test_deserialize_settings
      old_settings = {
        attributesToIndex: %w(attr1 attr2),
        numericAttributesToIndex: %w(attr1 attr2),
        slaves: %w(index1 index2)
      }

      new_settings = {
        searchableAttributes: %w(attr1 attr2),
        numericAttributesForFiltering: %w(attr1 attr2),
        replicas: %w(index1 index2)
      }

      deserialized_settings = deserialize_settings(old_settings)
      assert_equal new_settings, deserialized_settings
    end
  end
end
