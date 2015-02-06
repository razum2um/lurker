require 'simplecov'
SimpleCov.start do
  filters.clear # This will remove the :root_filter that comes via simplecov's defaults
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}\/lib\/lurker/)
  end
end

def example_path
  if rails_version = ENV['BUNDLE_GEMFILE'].to_s.match(/rails_\d\d/)
    File.expand_path("../../../tmp/lurker_app_#{rails_version}", __FILE__)
  else
    raise "Use `appraisal rails-XY cucumber ...` or export BUNDLE_GEMFILE=gemfiles/... explicitly"
  end
end

require 'fileutils'
require 'aruba/cucumber'

require 'rspec/expectations'
World(RSpec::Matchers)

require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require "#{example_path}/config/environment"
require 'database_cleaner'
require 'database_cleaner/cucumber'

Capybara.app = Rails.application
Capybara.javascript_driver = :poltergeist

DatabaseCleaner.strategy = :truncation

# see: https://github.com/colszowka/simplecov/issues/234
Aruba.configure do |config|
  config.before_cmd do |cmd|
    set_env 'SIMPLECOV_CMDNAME', Digest::MD5.hexdigest(cmd)
    set_env 'SIMPLECOV_ROOT',    File.expand_path('../../..', __FILE__)
  end
end

Before do
  @dirs = [example_path]
  @aruba_timeout_seconds = 30
  DatabaseCleaner.start
  if ENV['CLEAN']
    system "bin/spring stop"
    %w[lurker html public/lurker spec/requests spec/controllers].each do |dir_name|
      in_current_dir { _rm_rf(dir_name) }
    end
  end
end

After do |scenario|
  ActiveRecord::Base.connection.reconnect!
  DatabaseCleaner.clean
end

After('@selenium') do |scenario|
  save_and_open_page if scenario.failed? && !ENV['BUNDLE_GEMFILE'].match(/Gemfile\.ci/)
end
