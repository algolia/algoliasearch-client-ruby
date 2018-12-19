# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'securerandom'

describe 'Insights client' do
  before(:all) do
    @insights = Algolia::Insights.new(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_API_KEY'])

    client = Algolia::Client.new({
         :application_id => ENV['ALGOLIA_APPLICATION_ID'],
         :api_key => ENV['ALGOLIA_API_KEY']
     })

    @index = client.init_index(index_name('insights_client_1'))
    @index.delete_index rescue 'not fatal'
  end

  after(:all) do
    @index.delete_index rescue 'not fatal'
  end

  it 'should allow send event', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    event = {
        'eventType' => 'click',
        'eventName' => 'foo',
        'index' => @index.name,
        'userToken' => 'bar',
        'objectIds' => ['obj1', 'obj2']
    }

    response = @insights.send_event(event)
    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send events', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    event = {
        'eventType' => 'conversion',
        'eventName' => 'foo',
        'index' => @index.name,
        'userToken' => 'bar',
        'objectIDs' => ['obj1', 'obj2']
    }

    response = @insights.send_events([event])
    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send clicked object ids', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').clicked_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send clicked object ids after search', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').clicked_object_ids_after_search('eventName', @index.name, ['obj1', 'obj2'], [1, 2], "30d69d863dde81562ce277fbc0a3cf18")

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send clicked filters', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').clicked_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted objects ids', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').converted_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted objects ids after search', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').converted_object_ids_after_search('eventName', @index.name, ['obj1', 'obj2'], "30d69d863dde81562ce277fbc0a3cf18")

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted filters', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').converted_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send viewed object ids', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').viewed_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send viewed filters', :skip => RUBY_VERSION < Algolia::Insights::MIN_RUBY_VERSION do
    response = @insights.user('userToken').viewed_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end
end

