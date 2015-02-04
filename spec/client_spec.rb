# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

# avoid concurrent access to the same index
def safe_index_name(name)
  return name if ENV['TRAVIS'].to_s != "true"
  id = ENV['TRAVIS_JOB_NUMBER'].split('.').last
  "#{name}_travis-#{id}"
end

def is_include(array, attr, value)
  array.each do |elt|
    if elt[attr] == value
      return true
    end
  end
  return false
end

describe 'Client' do
  before(:all) do
    @index = Algolia::Index.new(safe_index_name("àlgol?a"))
    @index.delete_index rescue "not fatal"
  end

  after(:all) do
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

  it "should partial update a simple object, or add it if it doesn't exist" do
    res = @index.search("tonny@parker.org")
    res["hits"].length.should eq(0)
    @index.partial_update_object!({ :email => "tonny@parker.org" }, "1")
    res = @index.search("tonny@parker.org")
    res["hits"].length.should eq(1)
  end

  it "should partial update a simple object, but don't add it if it doesn't exist" do
    @index.partial_update_object!({ :email => "alex@boom.org" }, "51", false)
    res = @index.search("alex@boom.org")
    res["hits"].length.should eq(0)
  end

  it "should partial update a batch of objects, and add them if they don't exist" do
    batch = [
      { :objectID => "1", :email => "john@wanna.org" },
      { :objectID => "2", :email => "robert@wanna.org" }
    ]
    @index.partial_update_objects!(batch)
    res = @index.search("@wanna.org")
    res["hits"].length.should eq(2)
  end

  it "should partial update a batch of objects, but don't add them if they don't exist" do
    create_if_not_exits = false
    batch = [
      { :objectID => "11", :email => "john@be.org" },
      { :objectID => "22", :email => "robert@be.org" }
    ]
    @index.partial_update_objects!(batch, create_if_not_exits)
    res = @index.search("@be.org")
    res["hits"].length.should eq(0)
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
    expect { @index.save_object({ :objectID => 42 }.to_json) }.to raise_error(ArgumentError)
    expect { @index.save_objects([{}, ""]) }.to raise_error(ArgumentError)
    expect { @index.save_objects([1]) }.to raise_error(ArgumentError)
    expect { @index.save_objects!([1]) }.to raise_error(ArgumentError)
    expect { @index.save_object({ :foo => 42 }) }.to raise_error(ArgumentError) # missing objectID
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
    index = Algolia::Index.new(safe_index_name("àlgol?a"))
    begin
      index.delete_index!
    rescue
      # friends_2 does not exist
    end
    res = Algolia.list_indexes
    is_include(res['items'], 'name', safe_index_name('àlgol?a')).should eq(false)
    index.add_object!({ :name => "Robert" })
    resAfter = Algolia.list_indexes;
    is_include(resAfter['items'], 'name', safe_index_name('àlgol?a')).should eq(true)
  end

  it "should get a object" do
    @index.clear_index
    @index.add_object!({:firstname => "Robert"})
    @index.add_object!({:firstname => "Robert2"})
    res = @index.search('')
    res["nbHits"].should eq(2)
    object = @index.get_object(res['hits'][0]['objectID'])
    object['firstname'].should eq(res['hits'][0]['firstname'])

    object = @index.get_object(res['hits'][0]['objectID'], 'firstname')
    object['firstname'].should eq(res['hits'][0]['firstname'])

    objects = @index.get_objects([ res['hits'][0]['objectID'], res['hits'][1]['objectID'] ])
    objects.size.should eq(2)
  end

  it "should delete the object" do
    @index.clear
    @index.add_object!({:firstname => "Robert"})
    res = @index.search('')
    @index.search('')['nbHits'].should eq(1)
    @index.delete_object!(res['hits'][0]['objectID'])
    @index.search('')['nbHits'].should eq(0)
  end

  it "should delete several objects" do
    @index.clear
    @index.add_object!({:firstname => "Robert1"})
    @index.add_object!({:firstname => "Robert2"})
    res = @index.search('')
    @index.search('')['nbHits'].should eq(2)
    @index.delete_objects!(res['hits'].map { |h| h['objectID'] })
    @index.search('')['nbHits'].should eq(0)
  end

  it "should delete several objects by query" do
    @index.clear
    @index.add_object({:firstname => "Robert1"})
    @index.add_object!({:firstname => "Robert2"})
    @index.search('')['nbHits'].should eq(2)
    @index.delete_by_query('rob')
    @index.search('')['nbHits'].should eq(0)
  end

  it "should copy the index" do
    index = Algolia::Index.new(safe_index_name("àlgol?à"))
    begin
      @index.clear_index
      Algolia.delete_index index.name
    rescue
      # friends_2 does not exist
    end

    @index.add_object!({:firstname => "Robert"})
    @index.search('')['nbHits'].should eq(1)
    
    Algolia.copy_index!(safe_index_name("àlgol?a"), safe_index_name("àlgol?à"))
    @index.delete_index!
    
    index.search('')['nbHits'].should eq(1)
    index.delete_index!
  end

  it "should move the index" do
    @index.clear_index rescue "friends does not exist"
    index = Algolia::Index.new(safe_index_name("àlgol?à"))
    begin
      Algolia.delete_index! index.name
    rescue
      # friends_2 does not exist
    end

    @index.add_object!({:firstname => "Robert"})
    @index.search('')['nbHits'].should eq(1)
    
    Algolia.move_index!(safe_index_name("àlgol?a"), safe_index_name("àlgol?à"))
    
    index.search('')['nbHits'].should eq(1)
    index.delete_index
  end

  it "should retrieve the object" do
    @index.clear_index rescue "friends does not exist"
    @index.add_object!({:firstname => "Robert"})

    res = @index.browse

    res['hits'].size.should eq(1)
    res['hits'][0]['firstname'].should eq("Robert")
  end 

  it "should get logs" do
    res = Algolia.get_logs(0, 20, true)

    res['logs'].size.should > 0
  end

  it "should search on multipleIndex" do
    @index.clear_index! rescue "Not fatal"
    @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    res = Algolia.multiple_queries([{:index_name => safe_index_name("àlgol?a"), "query" => ""}])
    res["results"][0]["hits"].length.should eq(1)

    res = Algolia.multiple_queries([{"indexName" => safe_index_name("àlgol?a"), "query" => ""}], "indexName")
    res["results"][0]["hits"].length.should eq(1)
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
    res = @index.batch!(request)
    @index.search('')['nbHits'].should eq(4)
  end

  it "should allow an array of tags" do
    @index.add_object!({ :name => "P1", :_tags => "t1" })
    @index.add_object!({ :name => "P2", :_tags => "t1" })
    @index.add_object!({ :name => "P3", :_tags => "t2" })
    @index.add_object!({ :name => "P4", :_tags => "t3" })
    @index.add_object!({ :name => "P5", :_tags => ["t3", "t4"] })

    @index.search("", { :tagFilters => ["t1"] })['hits'].length.should eq(2)         # t1
    @index.search("", { :tagFilters => ["t1", "t2"] })['hits'].length.should eq(0)   # t1 AND t2
    @index.search("", { :tagFilters => ["t3", "t4"] })['hits'].length.should eq(1)   # t3 AND t4
    @index.search("", { :tagFilters => [["t1", "t2"]] })['hits'].length.should eq(3) # t1 OR t2
  end

  it "should be facetable" do
    @index.clear!
    @index.set_settings( { :attributesForFacetting => ["f", "g"] })
    @index.add_object!({ :name => "P1", :f => "f1", :g => "g1" })
    @index.add_object!({ :name => "P2", :f => "f1", :g => "g2" })
    @index.add_object!({ :name => "P3", :f => "f2", :g => "g2" })
    @index.add_object!({ :name => "P4", :f => "f3", :g => "g2" })

    res = @index.search("", { :facets => "f" })
    res['facets']['f']['f1'].should eq(2)
    res['facets']['f']['f2'].should eq(1)
    res['facets']['f']['f3'].should eq(1)

    res = @index.search("", { :facets => "f", :facetFilters => ["f:f1"] })
    res['facets']['f']['f1'].should eq(2)
    res['facets']['f']['f2'].should be_nil
    res['facets']['f']['f3'].should be_nil

    res = @index.search("", { :facets => "f", :facetFilters => ["f:f1", "g:g2"] })
    res['facets']['f']['f1'].should eq(1)
    res['facets']['f']['f2'].should be_nil
    res['facets']['f']['f3'].should be_nil

    res = @index.search("", { :facets => "f,g", :facetFilters => [["f:f1", "g:g2"]] })
    res['nbHits'].should eq(4)
    res['facets']['f']['f1'].should eq(2)
    res['facets']['f']['f2'].should eq(1)
    res['facets']['f']['f3'].should eq(1)

    res = @index.search("", { :facets => "f,g", :facetFilters => [["f:f1", "g:g2"], "g:g1"] })
    res['nbHits'].should eq(1)
    res['facets']['f']['f1'].should eq(1)
    res['facets']['f']['f2'].should be_nil
    res['facets']['f']['f3'].should be_nil
    res['facets']['g']['g1'].should eq(1)
    res['facets']['g']['g2'].should be_nil
  end

  it "should test keys" do
    resIndex = @index.list_user_keys
    newIndexKey = @index.add_user_key(['search'])
    newIndexKey['key'].should_not eq("")
    sleep 2 # no task ID here
    resIndexAfter = @index.list_user_keys
    is_include(resIndex['keys'], 'value', newIndexKey['key']).should eq(false)
    is_include(resIndexAfter['keys'], 'value', newIndexKey['key']).should eq(true)
    indexKey = @index.get_user_key(newIndexKey['key'])
    indexKey['acl'][0].should eq('search')
    @index.update_user_key(newIndexKey['key'], ['addObject'])
    sleep 2 # no task ID here
    indexKey = @index.get_user_key(newIndexKey['key'])
    indexKey['acl'][0].should eq('addObject')
    @index.delete_user_key(newIndexKey['key'])
    sleep 2 # no task ID here
    resIndexEnd = @index.list_user_keys
    is_include(resIndexEnd['keys'], 'value', newIndexKey['key']).should eq(false)


    res = Algolia.list_user_keys
    newKey = Algolia.add_user_key(['search'])
    newKey['key'].should_not eq("")
    sleep 2 # no task ID here
    resAfter = Algolia.list_user_keys
    is_include(res['keys'], 'value', newKey['key']).should eq(false)
    is_include(resAfter['keys'], 'value', newKey['key']).should eq(true)
    key = Algolia.get_user_key(newKey['key'])
    key['acl'][0].should eq('search')
    Algolia.update_user_key(newKey['key'], ['addObject'])
    sleep 2 # no task ID here
    key = Algolia.get_user_key(newKey['key'])
    key['acl'][0].should eq('addObject')
    Algolia.delete_user_key(newKey['key'])
    sleep 2 # no task ID here
    resEnd = Algolia.list_user_keys
    is_include(resEnd['keys'], 'value', newKey['key']).should eq(false)

    
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

  it "Check attributes list_indexes:" do
    res = Algolia::Index.all
    res.should have_key('items')     
    res['items'][0].should have_key('name')    
    res['items'][0]['name'].should be_a(String)    
    res['items'][0].should have_key('createdAt')    
    res['items'][0]['createdAt'].should be_a(String)    
    res['items'][0].should have_key('updatedAt')    
    res['items'][0]['updatedAt'].should be_a(String)    
    res['items'][0].should have_key('entries')    
    res['items'][0]['entries'].should be_a(Integer)    
    res['items'][0].should have_key('pendingTask')    
    [true, false].should include(res['items'][0]['pendingTask']) 
  end

  it 'Check attributes search : ' do
    res = @index.search('')
    res.should have_key('hits')     
    res['hits'].should be_a(Array)
    res.should have_key('page')     
    res['page'].should be_a(Integer)     
    res.should have_key('nbHits')     
    res['nbHits'].should be_a(Integer)     
    res.should have_key('nbPages')     
    res['nbPages'].should be_a(Integer)     
    res.should have_key('hitsPerPage')     
    res['hitsPerPage'].should be_a(Integer)     
    res.should have_key('processingTimeMS')     
    res['processingTimeMS'].should be_a(Integer)     
    res.should have_key('query')     
    res['query'].should be_a(String)     
    res.should have_key('params')     
    res['params'].should be_a(String)     
  end

  it 'Check attributes delete_index : ' do
    index = Algolia::Index.new(safe_index_name("àlgol?à2"))
    index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task = index.delete_index()
    task.should have_key('deletedAt')
    task['deletedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
  end

  it 'Check attributes clear_index : ' do
    task = @index.clear_index
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
  end
  
  it 'Check attributes add object : ' do
    task = @index.add_object({ :name => "John Doe", :email => "john@doe.org" })
    task.should have_key('createdAt')
    task['createdAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    task.should have_key('objectID')
    task['objectID'].should be_a(String)
  end

  it 'Check attributes add object id: ' do
    task = @index.add_object({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    #task.to_s.should eq("")
    task.should have_key('objectID')
    task['objectID'].should be_a(String)
    task['objectID'].should eq("1") 
  end

  it 'Check attributes partial update: ' do
    task = @index.partial_update_object({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    task.should have_key('objectID')
    task['objectID'].should be_a(String)
    task['objectID'].should eq("1")
  end

  it 'Check attributes delete object: ' do
    @index.add_object({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task = @index.delete_object("1")
    task.should have_key('deletedAt')
    task['deletedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
  end

  it 'Check attributes add objects: ' do
    task = @index.add_objects([{ :name => "John Doe", :email => "john@doe.org", :objectID => "1" }])
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    task.should have_key('objectIDs')
    task['objectIDs'].should be_a(Array)
  end

  it 'Check attributes browse: ' do
    res = @index.browse()
    res.should have_key('hits')
    res['hits'].should be_a(Array)
    res.should have_key('page')
    res['page'].should be_a(Integer)
    res.should have_key('nbHits')
    res['nbHits'].should be_a(Integer)
    res.should have_key('nbPages')
    res['nbPages'].should be_a(Integer)
    res.should have_key('hitsPerPage')
    res['hitsPerPage'].should be_a(Integer)
    res.should have_key('processingTimeMS')
    res['processingTimeMS'].should be_a(Integer)
    res.should have_key('query')
    res['query'].should be_a(String)
    res.should have_key('params')
    res['params'].should be_a(String)
  end

  it 'Check attributes get settings: ' do
    task = @index.set_settings({})
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
  end

  it 'Check attributes move_index : ' do
    index = Algolia::Index.new(safe_index_name("àlgol?à"))
    index2 = Algolia::Index.new(safe_index_name("àlgol?à2"))
    index2.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task = Algolia.move_index!(safe_index_name("àlgol?à2"), safe_index_name("àlgol?à"))
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    index.delete_index
  end

  it 'Check attributes copy_index : ' do
    index = Algolia::Index.new(safe_index_name("àlgol?à"))
    index2 = Algolia::Index.new(safe_index_name("àlgol?à2"))
    index2.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task = Algolia.copy_index!(safe_index_name("àlgol?à2"), safe_index_name("àlgol?à"))
    task.should have_key('updatedAt')
    task['updatedAt'].should be_a(String)
    task.should have_key('taskID')
    task['taskID'].should be_a(Integer)
    index.delete_index
    index2.delete_index
  end

  it 'Check attributes wait_task : ' do
    task = @index.add_object!({ :name => "John Doe", :email => "john@doe.org" }, "1")
    task = Algolia.client.get(Algolia::Protocol.task_uri(safe_index_name("àlgol?a"), task['objectID']))
    task.should have_key('status')
    task['status'].should be_a(String)
    task.should have_key('pendingTask')
    [true, false].should include(task['pendingTask']) 
  end

  it "Check add keys" do
    newIndexKey = @index.add_user_key(['search'])
    newIndexKey.should have_key('key')
    newIndexKey['key'].should be_a(String)
    newIndexKey.should have_key('createdAt')
    newIndexKey['createdAt'].should be_a(String)
    sleep 2 # no task ID here
    resIndex = @index.list_user_keys
    resIndex.should have_key('keys')
    resIndex['keys'].should be_a(Array)
    resIndex['keys'][0].should have_key('value')
    resIndex['keys'][0]['value'].should be_a(String)
    resIndex['keys'][0].should have_key('acl')
    resIndex['keys'][0]['acl'].should be_a(Array)
    resIndex['keys'][0].should have_key('validity')
    resIndex['keys'][0]['validity'].should be_a(Integer)
    indexKey = @index.get_user_key(newIndexKey['key'])
    indexKey.should have_key('value')
    indexKey['value'].should be_a(String)
    indexKey.should have_key('acl')
    indexKey['acl'].should be_a(Array)
    indexKey.should have_key('validity')
    indexKey['validity'].should be_a(Integer)
    task = @index.delete_user_key(newIndexKey['key'])
    task.should have_key('deletedAt')
    task['deletedAt'].should be_a(String)
  end

  it 'Check attributes log : ' do
    logs = Algolia.get_logs()
    logs.should have_key('logs')
    logs['logs'].should be_a(Array)
    logs['logs'][0].should have_key('timestamp')
    logs['logs'][0]['timestamp'].should be_a(String)
    logs['logs'][0].should have_key('method')
    logs['logs'][0]['method'].should be_a(String)
    logs['logs'][0].should have_key('answer_code')
    logs['logs'][0]['answer_code'].should be_a(String)
    logs['logs'][0].should have_key('query_body')
    logs['logs'][0]['query_body'].should be_a(String)
    logs['logs'][0].should have_key('answer')
    logs['logs'][0]['answer'].should be_a(String)
    logs['logs'][0].should have_key('url')
    logs['logs'][0]['url'].should be_a(String)
    logs['logs'][0].should have_key('ip')
    logs['logs'][0]['ip'].should be_a(String)
    logs['logs'][0].should have_key('query_headers')
    logs['logs'][0]['query_headers'].should be_a(String)
    logs['logs'][0].should have_key('sha1')
    logs['logs'][0]['sha1'].should be_a(String)
  end

  it 'should generate secured api keys' do
    key = Algolia.generate_secured_api_key('my_api_key', '(public,user1)')
    key.should eq(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), 'my_api_key', '(public,user1)'))
    key = Algolia.generate_secured_api_key('my_api_key', '(public,user1)', 42)
    key.should eq(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), 'my_api_key', '(public,user1)42'))
    key = Algolia.generate_secured_api_key('my_api_key', ['public'])
    key.should eq(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), 'my_api_key', 'public'))
    key = Algolia.generate_secured_api_key('my_api_key', ['public', ['premium','vip']])
    key.should eq(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), 'my_api_key', 'public,(premium,vip)'))
  end 

  it 'Check attributes multipleQueries' do
    res = Algolia.multiple_queries([{:index_name => safe_index_name("àlgol?a"), "query" => ""}])
    res.should have_key('results')
    res['results'].should be_a(Array)
    res['results'][0].should have_key('hits')     
    res['results'][0]['hits'].should be_a(Array)
    res['results'][0].should have_key('page')     
    res['results'][0]['page'].should be_a(Integer)     
    res['results'][0].should have_key('nbHits')     
    res['results'][0]['nbHits'].should be_a(Integer)     
    res['results'][0].should have_key('nbPages')     
    res['results'][0]['nbPages'].should be_a(Integer)     
    res['results'][0].should have_key('hitsPerPage')     
    res['results'][0]['hitsPerPage'].should be_a(Integer)     
    res['results'][0].should have_key('processingTimeMS')     
    res['results'][0]['processingTimeMS'].should be_a(Integer)     
    res['results'][0].should have_key('query')     
    res['results'][0]['query'].should be_a(String)     
    res['results'][0].should have_key('params')     
    res['results'][0]['params'].should be_a(String)  
  end

  it 'should handle disjunctive faceting' do
    index = Algolia::Index.new(safe_index_name("test_hotels"))
    index.set_settings :attributesForFacetting => ['city', 'stars', 'facilities']
    index.clear_index rescue nil
    index.add_objects! [
      { :name => 'Hotel A', :stars => '*', :facilities => ['wifi', 'bath', 'spa'], :city => 'Paris' },
      { :name => 'Hotel B', :stars => '*', :facilities => ['wifi'], :city => 'Paris' },
      { :name => 'Hotel C', :stars => '**', :facilities => ['bath'], :city => 'San Francisco' },
      { :name => 'Hotel D', :stars => '****', :facilities => ['spa'], :city => 'Paris' },
      { :name => 'Hotel E', :stars => '****', :facilities => ['spa'], :city => 'New York' },
    ]

    answer = index.search_disjunctive_faceting('h', ['stars', 'facilities'], { :facets => 'city' })
    answer['nbHits'].should eq(5)
    answer['facets'].size.should eq(1)
    answer['disjunctiveFacets'].size.should eq(2)

    answer = index.search_disjunctive_faceting('h', ['stars', 'facilities'], { :facets => 'city' }, { :stars => ['*'] })
    answer['nbHits'].should eq(2)
    answer['facets'].size.should eq(1)
    answer['disjunctiveFacets'].size.should eq(2)
    answer['disjunctiveFacets']['stars']['*'].should eq(2)
    answer['disjunctiveFacets']['stars']['**'].should eq(1)
    answer['disjunctiveFacets']['stars']['****'].should eq(2)

    answer = index.search_disjunctive_faceting('h', ['stars', 'facilities'], { :facets => 'city' }, { :stars => ['*'], :city => ['Paris'] })
    answer['nbHits'].should eq(2)
    answer['facets'].size.should eq(1)
    answer['disjunctiveFacets'].size.should eq(2)
    answer['disjunctiveFacets']['stars']['*'].should eq(2)
    answer['disjunctiveFacets']['stars']['****'].should eq(1)

    answer = index.search_disjunctive_faceting('h', ['stars', 'facilities'], { :facets => 'city' }, { :stars => ['*', '****'], :city => ['Paris'] })
    answer['nbHits'].should eq(3)
    answer['facets'].size.should eq(1)
    answer['disjunctiveFacets'].size.should eq(2)
    answer['disjunctiveFacets']['stars']['*'].should eq(2)
    answer['disjunctiveFacets']['stars']['****'].should eq(1)
  end

  it 'should apply jobs one after another if synchronous' do
    index = Algolia::Index.new(safe_index_name("sync"))
    begin
      index.add_object! objectID: 1
      answer = index.search('')
      answer['nbHits'].should eq(1)
      answer['hits'][0]['objectID'].to_i.should eq(1)
      index.clear_index!
      index.add_object! objectID: 2
      index.add_object! objectID: 3
      answer = index.search('')
      answer['nbHits'].should eq(2)
      answer['hits'][0]['objectID'].to_i.should_not eq(1)
    ensure
      index.delete_index
    end
  end
end

