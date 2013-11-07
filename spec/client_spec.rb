require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

# avoid concurrent access to the same index
def safe_index_name(name)
  return name if ENV['TRAVIS'].to_s != "true"
  id = ENV['TRAVIS_JOB_NUMBER'].split('.').last
  "#{name}_travis-#{id}"
end

describe 'Client' do
  before(:all) do
    @index = Algolia::Index.new(safe_index_name("friends"))
    @index.delete rescue "not fatal"
  end

  it "should add a simple object" do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" })
    res = @index.search("john")
    res["hits"].length.should eq(1)
  end

  it "should add a set of objects" do
    @index.add_objects!([
      { :name => "Another", :email => "another1@example.org" },
      { :name => "Another", :email => "another2@example.org" }
    ])
    res = @index.search("another")
    res["hits"].length.should eq(2)
  end

  it "should throw an exception if invalid argument" do
    expect { @index.add_object!([ {:name => "test"} ]) }.to raise_error(ArgumentError)
    expect { @index.add_objects!([ [ {:name => "test"} ] ]) }.to raise_error(ArgumentError)
  end

  it "should be thread safe" do
    threads = []
    64.times do
      t = Thread.new do
        10.times do
          res = @index.search("john")
          res["hits"].length.should eq(1)
        end
      end
      threads << t
    end
    threads.each { |t| t.join }
  end

  it "should clear the index" do
    @index.clear!
    @index.search("")["hits"].length.should eq(0)
  end

end
