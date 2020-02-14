require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'
require 'rspec/core/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

RSpec::Core::RakeTask.new(:spec)

task :default => :test

desc 'Run RuboCop on the entire project'
RuboCop::RakeTask.new('rubocop') do |task|
  task.fail_on_error = true
end
