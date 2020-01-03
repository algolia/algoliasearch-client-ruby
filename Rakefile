# typed: strong
# typed: strict
# typed: true
# typed: false
# typed: ignore
# typed: false
# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Run RuboCop on the entire project'
RuboCop::RakeTask.new('rubocop') do |task|
  task.fail_on_error = true
end
