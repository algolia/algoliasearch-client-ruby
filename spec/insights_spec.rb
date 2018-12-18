# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'securerandom'

describe 'Insights client' do
  before(:all) do
    @insights = Algolia::Insights.new(ENV['ALGOLIA_APPLICATION_ID_1'], ENV['ALGOLIA_ADMIN_KEY_1'])

    client = Algolia::Client.new({
         :application_id => ENV['ALGOLIA_APPLICATION_ID_1'],
         :api_key => ENV['ALGOLIA_ADMIN_KEY_1']
     })

    @index = client.init_index(index_name('insights_client_1'))
    @index.delete_index rescue 'not fatal'
  end

  after(:all) do
    @index.delete_index rescue 'not fatal'
  end

  it 'should allow send event' do
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

  it 'should allow send events' do
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

  it 'should allow send clicked object ids' do
    response = @insights.user('userToken').clicked_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send clicked object ids after search' do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    query_id = @index.search("john", { 'clickAnalytics' => true })['queryID']
    response = @insights.user('userToken').clicked_object_ids_after_search('eventName', @index.name, ['obj1', 'obj2'], [1, 2], query_id)

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send clicked filters' do
    response = @insights.user('userToken').clicked_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted objects ids' do
    response = @insights.user('userToken').converted_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted objects ids after search' do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    query_id = @index.search("john", { 'clickAnalytics' => true})['queryID']
    response = @insights.user('userToken').converted_object_ids_after_search('eventName', @index.name, ['obj1', 'obj2'], query_id)

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send converted filters' do
    response = @insights.user('userToken').converted_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send viewed object ids' do
    response = @insights.user('userToken').viewed_object_ids('eventName', @index.name, ['obj1', 'obj2'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end

  it 'should allow send viewed filters' do
    response = @insights.user('userToken').viewed_filters('eventName', @index.name, ['filter:foo', 'filter:bar'])

    response['status'].should eq(200)
    response['message'].should eq('OK')
  end
end

