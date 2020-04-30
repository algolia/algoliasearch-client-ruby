require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

task(:default) { system 'rake --tasks' }
task test: 'test:unit'

namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/algolia/unit/**/*_test.rb']
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/algolia/integration/**/*_test.rb']
  end

  desc 'Run unit and integration tests'
  task :all do
    Rake::Task['test:unit'].invoke
    Rake::Task['test:integration'].invoke
  end
end

RuboCop::RakeTask.new

desc 'Run linting, unit and integration tests'
task :all do
  Rake::Task['rubocop'].invoke
  Rake::Task['test:unit'].invoke
  Rake::Task['test:integration'].invoke
end
