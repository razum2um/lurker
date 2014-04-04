require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'

task :c do
  require 'pry'
  require 'lurker'
  require File.expand_path("../spec/dummy/config/environment", __FILE__)
  ARGV.clear
  Pry.start
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
