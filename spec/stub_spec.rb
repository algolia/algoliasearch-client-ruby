require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'webmock'

describe 'With a rate limited client' do

  before(:each) do
    WebMock.enable!
    Thread.current[:algolia_hosts] = nil
  end

  it "should pass the right headers" do
    WebMock.stub_request(:get, %r{https://.*\.algolia\.(io|net)/1/indexes/friends\?query=.*}).
      with(:headers => {'Content-Type'=>'application/json; charset=utf-8', 'User-Agent'=>"Algolia for Ruby #{Algolia::VERSION}", 'X-Algolia-Api-Key'=>ENV['ALGOLIA_API_KEY'], 'X-Algolia-Application-Id'=>ENV['ALGOLIA_APPLICATION_ID'], 'X-Forwarded-Api-Key'=>'ratelimitapikey', 'X-Forwarded-For'=>'1.2.3.4'}).
      to_return(:status => 200, :body => "{ \"hits\": [], \"fakeAttribute\": 1 }", :headers => {})
    Algolia.enable_rate_limit_forward ENV['ALGOLIA_API_KEY'], "1.2.3.4", "ratelimitapikey"
    index = Algolia::Index.new("friends")
    index.search('foo')['fakeAttribute'].should == 1
    index.search('bar')['fakeAttribute'].should == 1
  end

  it "should use original headers" do
    WebMock.stub_request(:get, %r{https://.*\.algolia\.(io|net)/1/indexes/friends\?query=.*}).
      with(:headers => {'Content-Type'=>'application/json; charset=utf-8', 'User-Agent'=>"Algolia for Ruby #{Algolia::VERSION}", 'X-Algolia-Api-Key'=>ENV['ALGOLIA_API_KEY'], 'X-Algolia-Application-Id'=>ENV['ALGOLIA_APPLICATION_ID'] }).
      to_return(:status => 200, :body => "{ \"hits\": [], \"fakeAttribute\": 2 }", :headers => {})    
    Algolia.disable_rate_limit_forward
    index = Algolia::Index.new("friends")
    index.search('bar')['fakeAttribute'].should == 2
  end

  it "should pass the right headers in the scope" do
    WebMock.stub_request(:get, %r{https://.*\.algolia\.(io|net)/1/indexes/friends\?query=.*}).
      with(:headers => {'Content-Type'=>'application/json; charset=utf-8', 'User-Agent'=>"Algolia for Ruby #{Algolia::VERSION}", 'X-Algolia-Api-Key'=>ENV['ALGOLIA_API_KEY'], 'X-Algolia-Application-Id'=>ENV['ALGOLIA_APPLICATION_ID'], 'X-Forwarded-Api-Key'=>'ratelimitapikey', 'X-Forwarded-For'=>'1.2.3.4'}).
      to_return(:status => 200, :body => "{ \"hits\": [], \"fakeAttribute\": 1 }", :headers => {})
    Algolia.with_rate_limits "1.2.3.4", "ratelimitapikey" do
      index = Algolia::Index.new("friends")
      index.search('foo')['fakeAttribute'].should == 1
      index.search('bar')['fakeAttribute'].should == 1
    end
  end

  after(:each) do
    WebMock.disable!
  end

end
