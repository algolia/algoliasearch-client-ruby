# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'securerandom'

describe 'Recommendation client' do
  before(:all) do
    @recommendation = Algolia::Recommendation.new(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_API_KEY'], 'eu')

    client = Algolia::Client.new({
         :application_id => ENV['ALGOLIA_APPLICATION_ID'],
         :api_key => ENV['ALGOLIA_API_KEY']
     })

    @index = client.init_index(index_name('recommendation_client_1'))
    @index.delete_index rescue 'not fatal'
  end

  after(:all) do
    @index.delete_index rescue 'not fatal'
  end

  it 'should get strategy', :skip => RUBY_VERSION < Algolia::Recommendation::MIN_RUBY_VERSION do
    strategy = @recommendation.get_personalization_strategy

    strategy.has_key?('eventsScoring').should eq(true)
    strategy['eventsScoring'][0].has_key?('eventName').should eq(true)
    strategy['eventsScoring'][0].has_key?('eventType').should eq(true)
    strategy['eventsScoring'][0].has_key?('score').should eq(true)
    strategy.has_key?('facetsScoring').should eq(true)
    strategy['facetsScoring'][0].has_key?('facetName').should eq(true)
    strategy['facetsScoring'][0].has_key?('score').should eq(true)
    strategy.has_key?('personalizationImpact').should eq(true)
  end
end

