require 'simplecov'

if ENV['COVERAGE']
  SimpleCov.start
end

require 'bundler/setup'
require 'algoliasearch'
require 'minitest/autorun'
require 'minitest/hooks'
require 'minitest/hell'

APPLICATION_ID_1   = ENV['ALGOLIA_APPLICATION_ID_1']
ADMIN_KEY_1        = ENV['ALGOLIA_ADMIN_KEY_1']
SEARCH_KEY_1       = ENV['ALGOLIA_SEARCH_KEY_1']
APPLICATION_ID_2   = ENV['ALGOLIA_APPLICATION_ID_2']
ADMIN_KEY_2        = ENV['ALGOLIA_ADMIN_KEY_2']
MCM_APPLICATION_ID = ENV['ALGOLIA_APPLICATION_ID_MCM']
MCM_ADMIN_KEY      = ENV['ALGOLIA_ADMIN_KEY_MCM']

class Minitest::Test
  parallelize_me!

  attr_reader :search_client

  include Minitest::Hooks
  @search_config  = Algolia::Search::Config.new(app_id: APPLICATION_ID_1, api_key: ADMIN_KEY_1, user_agent: 'test-ruby')
  @@search_client = Algolia::Search::Client.new(@search_config)

  @cleanup = begin
            indexes_list = @@search_client.list_indexes

            unless indexes_list.empty?
              yesterday         = Date.today.prev_day
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
  user = ENV['USER'] || 'unknown'

  instance = ENV['TRAVIS'].to_s == 'true' ? ENV['TRAVIS_JOB_NUMBER'] : user

  format('ruby_%<date>s_%<instance>s_%<name>s', date: date, instance: instance, name: name)
end

def get_mcm_user_name
  date = DateTime.now.strftime('%Y-%m-%d_%H:%M:%S')
  user = ENV['USER'] || 'unknown'

  instance = ENV['TRAVIS'].to_s == 'true' ? ENV['TRAVIS_JOB_NUMBER'] : user

  format('ruby_%<date>s_%<instance>s', date: date, instance: instance)
end

def generate_object(object_id = nil)
  object = {property: 'property'}
  if object_id
    object[:objectID] = object_id
  end

  object
end

def create_employee_records
  [
    {company: 'Algolia', name: 'Julien Lemoine', objectID: 'julien-lemoine'},
    {company: 'Algolia', name: 'Nicolas Dessaigne', objectID: 'nicolas-dessaigne'},
    {company: 'Amazon', name: 'Jeff Bezos'},
    {company: 'Apple', name: 'Steve Jobs'},
    {company: 'Apple', name: 'Steve Wozniak'},
    {company: 'Arista Networks', name: 'Jayshree Ullal'},
    {company: 'Google', name: 'Larry Page'},
    {company: 'Google', name: 'Rob Pike'},
    {company: 'Google', name: 'Serguey Brin'},
    {company: 'Microsoft', name: 'Bill Gates'},
    {company: 'SpaceX', name: 'Elon Musk'},
    {company: 'Tesla', name: 'Elon Musk'},
    {company: 'Yahoo', name: 'Marissa Mayer'}
  ]
end
