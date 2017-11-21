
if ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start
end

if ENV['TRAVIS'] && Object.const_defined?(:RUBY_ENGINE) && RUBY_ENGINE == "ruby"
  require 'coveralls'
  Coveralls.wear!
end

Bundler.setup :test

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'algoliasearch'
require 'rspec'

require 'webmock/rspec'
WebMock.disable!

require 'algolia/webmock'

raise "missing ALGOLIA_APPLICATION_ID or ALGOLIA_API_KEY environment variables" if ENV['ALGOLIA_APPLICATION_ID'].nil? || ENV['ALGOLIA_API_KEY'].nil?
Algolia.init :application_id => ENV['ALGOLIA_APPLICATION_ID'], :api_key => ENV['ALGOLIA_API_KEY']

RSpec.configure do |c|
  c.mock_with :rspec
end
