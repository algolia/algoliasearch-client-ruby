require 'minitest/autorun'
require 'algoliasearch'
require 'test_helper'

class BaseTest < Minitest::Test
  def setup
    check_environment_variables
  end
end
