require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'webmock'

describe 'With a rate limited client' do

  before(:all) do
    WebMock.enable!
    Thread.current[:algolia_hosts] = nil
  end

  it "should pass the right headers" do
    Algolia.enable_rate_limit_forward ENV['ALGOLIA_API_KEY'], "1.2.3.4", "ratelimitapikey"
    WebMock.stub_request(:get, %r{https://.*\.algolia\.io/1/indexes/friends\?query=.*}).
      with(:headers => {'Content-Type'=>'application/json; charset=utf-8', 'User-Agent'=>"Algolia for Ruby #{Algolia::VERSION}", 'X-Algolia-Api-Key'=>ENV['ALGOLIA_API_KEY'], 'X-Algolia-Application-Id'=>ENV['ALGOLIA_APPLICATION_ID'], 'X-Forwarded-Api-Key'=>'ratelimitapikey', 'X-Forwarded-For'=>'1.2.3.4'}).
      to_return(:status => 200, :body => "{ \"hits\": [], \"fakeAttribute\": 1 }", :headers => {})

    index = Algolia::Index.new("friends")
    index.search('foo')['fakeAttribute'].should == 1
    index.search('bar')['fakeAttribute'].should == 1
  end

  it "should previous headers" do
    Algolia.disable_rate_limit_forward
    WebMock.stub_request(:get, %r{https://.*\.algolia\.io/1/indexes/friends\?query=.*}).
      with(:headers => {'Content-Type'=>'application/json; charset=utf-8', 'User-Agent'=>"Algolia for Ruby #{Algolia::VERSION}", 'X-Algolia-Api-Key'=>ENV['ALGOLIA_API_KEY'], 'X-Algolia-Application-Id'=>ENV['ALGOLIA_APPLICATION_ID'] }).
      to_return(:status => 200, :body => "{ \"hits\": [], \"fakeAttribute\": 2 }", :headers => {})    

    index = Algolia::Index.new("friends")
    index.search('bar')['fakeAttribute'].should == 2
  end

  after(:all) do
    WebMock.disable!
  end

end
