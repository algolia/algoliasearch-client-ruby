require 'date'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'algoliasearch/version'

Gem::Specification.new do |spec|
  spec.name          = 'algoliasearch'
  spec.version       = Algolia::VERSION
  spec.authors       = ['Chloe Liban']
  spec.email         = ['chloe.liban@gmail.com']

  spec.date        = Date.today
  spec.licenses    = ['MIT']
  spec.summary     = 'A simple Ruby client for the algolia.com REST API'
  spec.description = 'A simple Ruby client for the algolia.com REST API'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem
  # that have been added into git.
  spec.files         = [
    '.rspec',
    '.travis.yml',
    'Gemfile',
    'Gemfile.lock',
    'README.md',
    'Rakefile',
    'algoliasearch.gemspec',
    'lib/algoliasearch/search_client.rb',
    'lib/algoliasearch/search_config.rb',
    'lib/algoliasearch/error.rb',
    'lib/algoliasearch/search_index.rb',
    'lib/algoliasearch/version.rb',
    'spec/algoliasearch_spec.rb'
  ]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'

  spec.add_development_dependency 'rake'

  spec.add_dependency 'faraday', '~> 0.15'
  spec.add_dependency 'multi_json', '~> 1.0'

  spec.add_development_dependency 'httpx'
  spec.add_development_dependency 'm'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-hooks'
  spec.add_development_dependency 'minitest-proveit'
  spec.add_development_dependency 'mocha'
end
