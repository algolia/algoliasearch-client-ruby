require 'simplecov'

if ENV['COVERAGE']
  SimpleCov.start
end

require 'bundler/setup'
require 'algoliasearch'
require 'minitest/autorun'
require 'minitest/hooks'

APPLICATION_ID_1 = ENV['ALGOLIA_APPLICATION_ID_1']
ADMIN_KEY_1 = ENV['ALGOLIA_ADMIN_KEY_1']
SEARCH_KEY_1 = ENV['ALGOLIA_SEARCH_KEY_1']
APPLICATION_ID_2 = ENV['ALGOLIA_APPLICATION_ID_2']
ADMIN_KEY_2 = ENV['ALGOLIA_ADMIN_KEY_2']
MCM_APPLICATION_ID = ENV['ALGOLIA_APPLICATION_ID_MCM']
MCM_ADMIN_KEY = ENV['ALGOLIA_ADMIN_KEY_MCM']

class Minitest::Test
  include Minitest::Hooks
  @@search_config = Algolia::Search::Config.new(app_id: APPLICATION_ID_1, api_key: ADMIN_KEY_1, user_agent: 'test-ruby')
  @@search_client = Algolia::Search::Client.new(@@search_config)

  @@cleanup = begin
            indexes_list = @@search_client.list_indexes

            unless indexes_list.empty?
              yesterday = Date.today.prev_day
              indexes_to_delete = indexes_list['items'].select do |index|
                index['name'].include?('ruby') && Date.parse(index['createdAt']) <= yesterday
              end

              operations = []

              unless indexes_to_delete.empty?
                indexes_to_delete.each do |index|
                  operations << {action: 'delete', indexName: index['name']}
                end

                @@search_client.multiple_batch(operations)
              end
            end
          end
end

def check_environment_variables
  raise ArgumentError, 'ALGOLIA_APPLICATION_ID_1 must be defined' if ENV['ALGOLIA_APPLICATION_ID_1'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_ADMIN_KEY_1 must be defined' if ENV['ALGOLIA_ADMIN_KEY_1'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_SEARCH_KEY_1 must be defined' if ENV['ALGOLIA_SEARCH_KEY_1'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_APPLICATION_ID_2 must be defined' if ENV['ALGOLIA_APPLICATION_ID_2'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_ADMIN_KEY_2 must be defined' if ENV['ALGOLIA_ADMIN_KEY_2'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_APPLICATION_ID_MCM must be defined' if ENV['ALGOLIA_APPLICATION_ID_MCM'].to_s.strip.empty?
  raise ArgumentError, 'ALGOLIA_ADMIN_KEY_MCM must be defined' if ENV['ALGOLIA_ADMIN_KEY_MCM'].to_s.strip.empty?
end

def get_test_index_name(name)
  date = DateTime.now.strftime('%Y-%m-%d_%H:%M:%S')
  user = ENV['USER'] ? ENV['USER'] : 'unknown'

  instance = ENV['TRAVIS'].to_s == 'true' ? ENV['TRAVIS_JOB_NUMBER'] : user

  'ruby_%s_%s_%s' % [date, instance, name]
end

def get_mcm_user_name
  date = DateTime.now.strftime('%Y-%m-%d_%H:%M:%S')
  user = ENV['USER'] ? ENV['USER'] : 'unknown'

  instance = ENV['TRAVIS'].to_s == 'true' ? ENV['TRAVIS_JOB_NUMBER'] : user

  'ruby_%s_%s' % [date, instance]
end
