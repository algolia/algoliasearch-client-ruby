require 'English'
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'algolia/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'algolia'
  s.version     = Algolia::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['https://alg.li/support']
  s.homepage    = 'https://github.com/algolia/algoliasearch-client-ruby'
  s.summary     = 'A simple Ruby client for the algolia.com REST API'
  s.description = 'A simple Ruby client for the algolia.com REST API'
  s.licenses    = ['MIT']

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/algolia/algoliasearch-client-ruby/issues',
    'source_code_uri' => 'https://github.com/algolia/algoliasearch-client-ruby',
    'rubygems_mfa_required' => 'true'
  }

  s.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables   = []
  s.require_paths = ['lib']

  s.add_dependency 'faraday', '>= 1.0.1', '< 3.0'
  s.add_dependency 'faraday-net_http_persistent', ['>= 0.15', '< 3']
  s.add_dependency 'base64', '>= 0.2.0', '< 1'

  s.add_dependency 'net-http-persistent'

  s.add_development_dependency 'bundler', '>= 2.4.10'
  s.add_development_dependency 'rake'
end
