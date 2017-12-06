source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Load algoliasearch.gemspec dependencies
gemspec

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
