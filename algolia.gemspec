# -*- encoding: utf-8 -*-

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "algolia/version"
require 'date'

Gem::Specification.new do |s|
  s.name        = "algolia"
  s.version     = Algolia::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Algolia"]
  s.email       = ["support@algolia.com"]
  s.homepage    = "https://github.com/algolia/algoliasearch-client-ruby"
  s.summary     = "A simple Ruby client for the algolia.com REST API"
  s.description = "A simple Ruby client for the algolia.com REST API"
  s.licenses    = ["MIT"]
  s.date        = Date.today

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/algolia/algoliasearch-client-ruby/issues',
    'source_code_uri' => 'https://github.com/algolia/algoliasearch-client-ruby'
  }

  s.files         = `find *`.split("\n").uniq.sort.select { |f| !f.empty? }
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_dependency 'faraday', '>= 1.0.1', '< 3.0'
  s.add_dependency 'faraday-net_http_persistent', ['>= 0.15', '< 3']

  s.add_dependency 'net-http-persistent'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end
