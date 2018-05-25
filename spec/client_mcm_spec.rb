# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

Algolia.init :application_id => ENV['ALGOLIA_APP_ID_MCM'], :api_key => ENV['ALGOLIA_API_KEY_MCM']

# avoid concurrent access to the same index
def safe_user_id(name)
  return name if ENV['TRAVIS'].to_s != "true"
  "#{name}-#{ENV['TRAVIS_JOB_NUMBER']}"
end

describe 'Multi Cluster Management', :mcm => true do

  before(:all) do
    @client = Algolia.client
    @user_id = safe_user_id('ruby-client-2')
    clusters = @client.list_clusters
    @cluster_name = clusters['clusters'][0]["clusterName"]
  end

  it 'should list clusters' do
    clusters = @client.list_clusters
    entry = clusters['clusters'][0]
      entry.has_key?("clusterName").should eq(true)
    entry.has_key?("nbRecords").should eq(true)
    entry.has_key?("nbUserIDs").should eq(true)
    entry.has_key?("dataSize").should eq(true)
    entry.count.should eq(4)
  end

  it 'should list user ids' do
    ids = @client.list_user_ids
    ids['userIDs'].count.should eq(20)

    entry = ids['userIDs'][0]
    entry.has_key?("userID").should eq(true)
    entry.has_key?("clusterName").should eq(true)
    entry.has_key?("nbRecords").should eq(true)
    entry.has_key?("dataSize").should eq(true)
    entry.count.should eq(4)

    less_ids = @client.list_user_ids(0, 3)
    less_ids['userIDs'].count.should eq(3)
  end

  it 'should assign a user to a cluster' do
    @client.assign_user_id(@user_id, @cluster_name)
    sleep(2)
  end

  it 'should get the created user id' do
    id = @client.get_user_id(@user_id)
    id["userID"].should eq(@user_id)
    id["clusterName"].should eq(@cluster_name)
    id.has_key?("nbRecords").should eq(true)
    id.has_key?("dataSize").should eq(true)
  end

  it "should find a user_id" do
    res = @client.search_user_id(@user_id, nil, 0, 22)
    res["hitsPerPage"].should eq(22)
    item = res["hits"][0]
    item["userID"].should eq(@user_id)
    item["clusterName"].should eq(@cluster_name)
  end

  it "should remove a user_id" do
    res = @client.remove_user_id(@user_id)
    sleep(2)
    search = @client.search_user_id(@user_id)
    if search["nbHits"] > 0
      item = search["hits"][0]
      item["userID"].should_not eq(@user_id)
    end
  end

end
