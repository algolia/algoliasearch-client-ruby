# encoding: UTF-8
require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe 'Insights' do

  before(:context) do
    @insights = Algolia::Insights.new({
                                     :application_id => ENV['ALGOLIA_APP_ID'] || ENV['ALGOLIA_APPLICATION_ID'],
                                     :api_key => ENV['ALGOLIA_API_KEY']
                                 })
  end

  context 'should manage AB Tests' do
    it "should send a click event to Insights API" do
      response = @insights.user('abcdef').clicked_object_ids(
                                             "Some event from Integration tests",
                                             "the_index_name",
                                             "ObjectID-unique"
      )

      response.count.should.be eq(1)

    end
  end

end
