# typed: strong

source 'https://rubygems.org'
gem "ffi", "= 1.16.3"

# Specify your gem's dependencies in algolia.gemspec
gemspec

gem 'minitest-ci'

group :development do
  gem 'git-precommit'
  gem 'steep' if RUBY_VERSION >= '2.5'
  gem 'yard'
end

group :test do
  gem 'simplecov'
end
