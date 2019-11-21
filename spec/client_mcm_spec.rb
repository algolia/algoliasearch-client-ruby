# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))
require 'securerandom'

# avoid concurrent access to the same index
def safe_user_id(name)
  name << '-' + SecureRandom.hex(4)
  if ENV['TRAVIS'].to_s == 'true'
    name << '-' + ENV['TRAVIS_JOB_NUMBER'].to_s
  end
  name
end

describe 'Multi Cluster Management', :mcm => true do

  before(:all) do
    @client = Algolia::Client.new({
      :application_id => ENV['ALGOLIA_APP_ID_MCM'],
      :api_key => ENV['ALGOLIA_API_KEY_MCM']
    })
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

  it 'should assign a user to a cluster' do
    @client.assign_user_id(@user_id, @cluster_name)
  end

  it 'should list user ids' do
    ids = @client.list_user_ids

    ids['userIDs'].count.should be > 0

    entry = ids['userIDs'][0]
    entry.has_key?("userID").should eq(true)
    entry.has_key?("clusterName").should eq(true)
    entry.has_key?("nbRecords").should eq(true)
    entry.has_key?("dataSize").should eq(true)
    entry.count.should eq(4)

    less_ids = @client.list_user_ids(0, 1)
    less_ids['userIDs'].count.should eq(1)
  end

  it 'should get the created user id' do
    id = auto_retry do
      @client.get_user_id(@user_id)
    end

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
    res = auto_retry do
      @client.remove_user_id(@user_id)
    end
    res["deletedAt"].should_not eq(nil)
  end

  it "should tell if pending mappings exist and retrieve their mappings" do
    res = auto_retry do
      @client.has_pending_mappings(true)
    end
    expect(res).not_to be nil
    expect(res["pending"]).to be true
    expect(res.has_key?("clusters")).to be true
  end

  it "should tell if pending mappings exist" do
    res = auto_retry do
      @client.has_pending_mappings(false)
    end
    expect(res["pending"]).to be true
    expect(res.has_key?("clusters")).to be false
  end

end
