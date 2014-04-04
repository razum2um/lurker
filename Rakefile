require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'

desc 'pry console for gem'
task :c do
  require 'pry'
  require 'lurker'
  require File.expand_path("../spec/dummy/config/environment", __FILE__)
  ARGV.clear
  Pry.start
end

RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:cucumber)

EXAMPLE_PATH = './tmp/example_app'

namespace :clobber do
  desc "clobber the generated app"
  task :app do
    in_example_app "bin/spring stop" if File.exist?("#{EXAMPLE_PATH}/bin/spring")
    rm_rf EXAMPLE_PATH
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    unless File.directory?(EXAMPLE_PATH)
      sh "bundle exec rails new #{EXAMPLE_PATH} -m #{File.expand_path '../templates/example_app.rb', __FILE__} --skip-javascript --skip-sprockets --skip-git --skip-test-unit --skip-keeps"
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_example_app "bin/rake rails:template LOCATION='../../templates/generate_stuff.rb'"
  end
end

def in_example_app(command)
  Dir.chdir(EXAMPLE_PATH) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

desc 'destroys & recreates new test app'
task :regenerate => ["clobber:app", "generate:app", "generate:stuff"]

task :default => [:spec, :regenerate, :cucumber]

