# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

def wait_abtest_operation(analytics, id, &block)
  1.upto(60) do # do not wait too long
    begin
      ab = analytics.get_ab_test(id)
      if block_given?
        return if yield ab
        # not found
        sleep 1
        next
      end
      return
    rescue
      # not found
      sleep 1
    end
  end
end


def wait_abtest_deleted(analytics, id)
  1.upto(60) do # do not wait too long
    begin
      ab = analytics.get_ab_test(id)
      sleep 1
      next
    rescue
      return
    end
  end
end

describe 'Analytics' do
  let(:abtest_id) { nil }

  before(:context) do
    client = Algolia::Client.new({
                                      :application_id => ENV['ALGOLIA_APP_ID'] || ENV['ALGOLIA_APPLICATION_ID'],
                                      :api_key => ENV['ALGOLIA_API_KEY']
                                  })
    @analytics = client.init_analytics
    @index_name = safe_index_name('àlgol?à-ruby-ABTest-'+rand(100).to_s+'tmp')

    @index = client.init_index(@index_name)
    @index.set_settings!({:replicas => [@index_name + '-alt']})
    @index.add_objects!(['record' => 'I need this index'])
  end

  after(:context) do
    @index.delete_index rescue "not fatal"
  end

  context 'should manage AB Tests' do
    it "should get a list of AB Tests" do
      response = @analytics.get_ab_tests({ :offset => 0, :limit => 3 })
      response['abtests'].count.should eq(response['count'])

      if response['count'] > 0
        abtest = response['abtests'][0]
        abtest.has_key?("abTestID").should eq(true)
        abtest.has_key?("status").should eq(true)
        abtest.has_key?("variants").should eq(true)
      end
    end

    it "should add a new AB test, retrieve it, stop it and delete it" do
      tomorrow = Time.now + 24*60*60
      abtest_to_add = {
          :name => "Some AB Test for integration tests",
          :variants => [
              { :index => @index_name, :trafficPercentage => 90, :description => "API client tests" },
              { :index => @index_name + "-alt", :trafficPercentage => 10 },
          ],
          :endAt => tomorrow.strftime("%Y-%m-%dT%H:%M:%SZ"),
      }
      res = @analytics.add_ab_test(abtest_to_add)
      @analytics.wait_task(res['index'], res['taskID'])
      abtest_id = res['abTestID']


    # it "should get the newly added AB test" do
      abtest = @analytics.get_ab_test(abtest_id)

      abtest['abTestID'].should eq(abtest_id)
      abtest.has_key?("status").should eq(true)
      abtest.has_key?("variants").should eq(true)


    # it "should stop the AB test" do
      res = @analytics.stop_ab_test(abtest_id)
      @analytics.wait_task(res['index'], res['taskID'])
      wait_abtest_operation(@analytics, abtest_id) do |ab|
        ab['status'] == "stopped"
      end

      abtest = @analytics.get_ab_test(abtest_id)
      abtest['status'].should eq("stopped")


    # it "should delete the AB test" do
      res = @analytics.delete_ab_test(abtest_id)
      @analytics.wait_task(res['index'], res['taskID'])
      wait_abtest_deleted(@analytics, abtest_id)

      abtest = @analytics.get_ab_test(abtest_id) rescue "it's deleted"
      abtest.should eq("it's deleted")
    end
  end

end
