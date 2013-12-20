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
    expect { @index.save_object(1) }.to raise_error(ArgumentError)
    expect { @index.save_object("test") }.to raise_error(ArgumentError)
    expect { @index.save_object({ objectID: 42 }.to_json) }.to raise_error(ArgumentError)
    expect { @index.save_objects([{}, ""]) }.to raise_error(ArgumentError)
    expect { @index.save_objects([1]) }.to raise_error(ArgumentError)
    expect { @index.save_objects!([1]) }.to raise_error(ArgumentError)
    expect { @index.save_object({ foo: 42 }) }.to raise_error(ArgumentError) # missing objectID
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

  it "should allow an array of tags" do
    @index.add_object!({ :name => "P1", :_tags => "t1" })
    @index.add_object!({ :name => "P2", :_tags => "t1" })
    @index.add_object!({ :name => "P3", :_tags => "t2" })
    @index.add_object!({ :name => "P4", :_tags => "t3" })
    @index.add_object!({ :name => "P5", :_tags => ["t3", "t4"] })

    @index.search("", { tagFilters: ["t1"] })['hits'].length.should eq(2)         # t1
    @index.search("", { tagFilters: ["t1", "t2"] })['hits'].length.should eq(0)   # t1 AND t2
    @index.search("", { tagFilters: ["t3", "t4"] })['hits'].length.should eq(1)   # t3 AND t4
    @index.search("", { tagFilters: [["t1", "t2"]] })['hits'].length.should eq(3) # t1 OR t2
  end

  it "should be facetable" do
    @index.clear!
    @index.set_settings( { attributesForFacetting: ["f", "g"] })
    @index.add_object!({ :name => "P1", :f => "f1", :g => "g1" })
    @index.add_object!({ :name => "P2", :f => "f1", :g => "g2" })
    @index.add_object!({ :name => "P3", :f => "f2", :g => "g2" })
    @index.add_object!({ :name => "P4", :f => "f3", :g => "g2" })

    res = @index.search("", { facets: "f" })
    res['facets']['f']['f1'].should eq(2)
    res['facets']['f']['f2'].should eq(1)
    res['facets']['f']['f3'].should eq(1)

    res = @index.search("", { facets: "f", facetFilters: ["f:f1"] })
    res['facets']['f']['f1'].should eq(2)
    res['facets']['f']['f2'].should be_nil
    res['facets']['f']['f3'].should be_nil

    res = @index.search("", { facets: "f", facetFilters: ["f:f1", "g:g2"] })
    res['facets']['f']['f1'].should eq(1)
    res['facets']['f']['f2'].should be_nil
    res['facets']['f']['f3'].should be_nil
  end

end
