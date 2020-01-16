require 'bundler/setup'
require 'algoliasearch'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:example, type: :request) do
    WebMock.disable!
  end

  config.before(:example, type: :unit) do
    WebMock.enable!
  end
end
