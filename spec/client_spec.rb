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
    @index.delete_index rescue "not fatal"
  end

  it "should add a simple object" do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    res = @index.search("john")
    res["hits"].length.should eq(1)
  end

  it "should partial update a simple object" do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    res = @index.search("john")
    res["hits"].length.should eq(1)
    @index.partial_update_object!({ :name => "Robert Doe"}, "1")
    res = @index.search("robert")
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

  it "should partial update a simple object" do
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "2")
    res = @index.search("john")
    res["hits"].length.should eq(2)
    @index.partial_update_objects!([{ :name => "Robert Doe", :objectID => "1"}, { :name => "Robert Doe", :objectID => "2"}])
    res = @index.search("robert")
    res["hits"].length.should eq(2)
  end

  it "should save a set of objects with their ids" do
    @index.save_object!({ :name => "objectid", :email => "objectid1@example.org", :objectID => 101 })
    res = @index.search("objectid")
    res["hits"].length.should eq(1)
  end

  it "should save a set of objects with their ids" do
    @index.save_objects!([
      { :name => "objectid", :email => "objectid1@example.org", :objectID => 101 },
      { :name => "objectid", :email => "objectid2@example.org", :objectID => 102 }
    ])
    res = @index.search("objectid")
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
          res["hits"].length.should eq(2)
        end
      end
      threads << t
    end
    threads.each { |t| t.join }
  end

  if !defined?(RUBY_ENGINE) || RUBY_ENGINE != 'jruby'
    it "should be fork safe" do
      8.times do
        Process.fork do
          10.times do
            res = @index.search("john")
            res["hits"].length.should eq(2)
          end
        end
      end
      Process.waitall
    end
  end

  it "should clear the index" do
    @index.clear!
    @index.search("")["hits"].length.should eq(0)
  end

  it "should have another index after" do
    index = Algolia::Index.new(safe_index_name("friends_2"))
    begin
      index.delete_index
      sleep 4 # Dirty but temporary
    rescue
      # friends_2 does not exist
    end
    res = Algolia.list_indexes
    index.add_object!({ :name => "Robert" })
    resAfter = Algolia.list_indexes;

    res['items'].size.should eq(resAfter['items'].size - 1)
  end

  it "should get a object" do
    @index.add_object!({:firstname => "Robert"})
    res = @index.search('')
    @index.search("")["nbHits"].should eq(1)
    object = @index.get_object(res['hits'][0]['objectID'])
    object['firstname'].should eq('Robert')
    object = @index.get_object(res['hits'][0]['objectID'], 'firstname')
    object['firstname'].should eq('Robert') 
  end

  it "should delete the object" do
    @index.clear
    @index.add_object!({:firstname => "Robert"})
    res = @index.search('')
    @index.search('')['nbHits'].should eq(1)
    object = @index.delete_object!(res['hits'][0]['objectID'])
    @index.search('')['nbHits'].should eq(0)
  end

  it "should copy the index" do
    index = Algolia::Index.new(safe_index_name("friends_2"))
    begin
      @index.clear_index
      index.delete_index
    rescue
      # friends_2 does not exist
    end

    @index.add_object!({:firstname => "Robert"})
    @index.search('')['nbHits'].should eq(1)
    
    Algolia.copy_index(safe_index_name('friends'), safe_index_name('friends_2'))
    @index.delete_index
    
    index.search('')['nbHits'].should eq(1)
  end

  it "should move the index" do
    @index.clear_index rescue "friends does not exist"
    index = Algolia::Index.new(safe_index_name("friends_2"))
    begin
      index.delete_index
    rescue
      # friends_2 does not exist
    end

    @index.add_object!({:firstname => "Robert"})
    @index.search('')['nbHits'].should eq(1)
    
    Algolia.move_index(safe_index_name('friends'), safe_index_name('friends_2'))
    
    index.search('')['nbHits'].should eq(1)
  end

  it "should retrieve the object" do
    @index.clear_index rescue "friends does not exist"
    @index.add_object!({:firstname => "Robert"})

    res = @index.browse

    res['hits'].size.should eq(1)
    res['hits'][0]['firstname'].should eq("Robert")
  end 

  it "should get logs" do
    res = Algolia.get_logs

    res['logs'].size.should > 0
  end

  it "shoud accept custom batch" do
    @index.clear_index! rescue "Not fatal"
    request = { "requests" => [
      {
        "action" => "addObject",
        "body" => {"firstname" => "Jimmie", 
        "lastname" => "Barninger"}
      },
      {
        "action" => "addObject",
        "body" => {"firstname" => "Warren", 
        "lastname" => "Speach"}
      },
      {
        "action" => "updateObject",
        "body" => {"firstname" => "Jimmie", 
        "lastname" => "Barninger",
        "objectID" => "43"}
      },
      {
        "action" => "updateObject",
        "body" => {"firstname" => "Warren", 
        "lastname" => "Speach"},
        "objectID" => "42"
      }
      ]}
    res = @index.batch(request)
    @index.search('')['nbHits'].should eq(4)
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

  it "should test keys" do
    resIndex = @index.list_user_keys
    newIndexKey = @index.add_user_key(['search'])
    newIndexKey['key'].should_not eq("")
    resIndexAfter = @index.list_user_keys
    resIndex['keys'].size.should eq(resIndexAfter['keys'].size - 1)
    indexKey = @index.get_user_key(newIndexKey['key'])
    indexKey['acl'][0].should eq('search')
    @index.delete_user_key(newIndexKey['key'])
    sleep 1 # Dirty but temporary
    resIndexEnd = @index.list_user_keys
    resIndex['keys'].size.should eq(resIndexEnd['keys'].size)


    res = Algolia.list_user_keys
    newKey = Algolia.add_user_key(['search'])
    newKey['key'].should_not eq("")
    resAfter = Algolia.list_user_keys
    res['keys'].size.should eq(resAfter['keys'].size - 1)
    key = Algolia.get_user_key(newKey['key'])
    key['acl'][0].should eq('search')
    Algolia.delete_user_key(newKey['key'])
    sleep 1 # Dirty but temporary
    resEnd = Algolia.list_user_keys
    res['keys'].size.should eq(resEnd['keys'].size)

    
  end

  it "should check functions" do
    @index.get_settings
    @index.list_user_keys
    Algolia.list_user_keys

  end

  it "should handle slash in objectId" do
    @index.clear_index!()
    @index.add_object!({:firstname => "Robert", :objectID => "A/go/?a"})
    res = @index.search('')
    @index.search("")["nbHits"].should eq(1)
    object = @index.get_object(res['hits'][0]['objectID'])
    object['firstname'].should eq('Robert')
    object = @index.get_object(res['hits'][0]['objectID'], 'firstname')
    object['firstname'].should eq('Robert') 

    @index.save_object!({:firstname => "George", :objectID => "A/go/?a"})
    res = @index.search('')
    @index.search("")["nbHits"].should eq(1)
    object = @index.get_object(res['hits'][0]['objectID'])
    object['firstname'].should eq('George')

    @index.partial_update_object!({:firstname => "Sylvain", :objectID => "A/go/?a"})
    res = @index.search('')
    @index.search("")["nbHits"].should eq(1)
    object = @index.get_object(res['hits'][0]['objectID'])
    object['firstname'].should eq('Sylvain')

  end


end
