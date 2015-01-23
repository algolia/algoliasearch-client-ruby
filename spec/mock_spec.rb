require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

require 'webmock'
WebMock.disable!

require 'algolia/webmock'

describe 'With a mocked client' do

  before(:each) do
    WebMock.enable!
    Algola.load_webmocks!
    Thread.current[:algolia_hosts] = nil # reset session objects
  end

  it "should add a simple object" do
    index = Algolia::Index.new("friends")
    index.add_object!({ :name => "John Doe", :email => "john@doe.org" })
    index.search('').should == {} # mocked
    index.list_user_keys
    index.browse
    index.clear
    index.delete
  end

  after(:each) do
    WebMock.disable!
  end

end
