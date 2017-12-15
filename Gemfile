source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Load algoliasearch.gemspec dependencies
gemspec

# See https://github.com/algolia/algoliasearch-client-ruby/pull/257/files/36bcd0b1c4d05776dcbdb362c15a609c81f41cde
if RUBY_VERSION < '1.9.3'
  gem 'hashdiff', '< 0.3.6' # Hashdiff 0.3.6 no longer supports Ruby 1.8
end

gem 'rubysl', '~> 2.0', :platform => :rbx

group :development do
  gem 'highline', '< 1.7.0'
  gem 'coveralls'
  gem 'safe_yaml', '~> 1.0.4'
  gem 'travis'
  gem 'rake'
  gem 'rdoc'
end

group :test do
  gem 'rspec', '>= 2.5.0'
  gem 'redgreen'
  gem 'webmock'
  gem 'simplecov'
  gem 'mime-types', '< 2.0'
end
