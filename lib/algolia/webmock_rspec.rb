require 'algolia/webmock'

RSpec.configure do |config|
  config.before :each do
    Algolia.load_webmocks!
  end
end
