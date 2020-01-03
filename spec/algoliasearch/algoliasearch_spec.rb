require 'algoliasearch'

RSpec.describe Algoliasearch do
  it 'has a version number' do
    expect(Algoliasearch::VERSION).not_to be nil
  end

  # it 'fails with wrong credentials' do
  #   client = Algoliasearch::Client.create(app_id: 'test', api_key: 'test')
  #   index = client.init_index('contacts')
  #   res = index.search('test')
  #   expect(res.status).to be 403
  # end
  #
  # it 'makes a search' do
  #   client = Algoliasearch::Client.create(app_id: ENV['ALGOLIA_APP_ID'], api_key: ENV['ALGOLIA_API_KEY'])
  #   index = client.init_index('contacts')
  #   res = index.search('test')
  #   expect(res.status).to be 200
  # end
end
