# encoding: utf-8

require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require File.expand_path('../lib/algolia/version', __FILE__)

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = Algolia::VERSION
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "algoliasearch #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Bump gem version'
task :semver, [:version] do |t, args|
  File.open(File.expand_path('../lib/algolia/version.rb', __FILE__), 'w') do |file|
    file.write <<~SEMVER
      module Algolia
        VERSION = "#{args[:version]}"
      end
    SEMVER
  end
end

module Bundler
  class GemHelper
    def version_tag
      "#{version}"
    end
  end
end
