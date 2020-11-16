require 'simplecov'
SimpleCov.start do
  filters.clear # This will remove the :root_filter that comes via simplecov's defaults
  add_filter do |src|
    !(src.filename =~ /^#{SimpleCov.root}\/lib\/lurker/)
  end
end

def relative_example_path
  if rails_version = ENV['BUNDLE_GEMFILE'].to_s.match(/rails_\d+/)
    "tmp/lurker_app_#{rails_version}"
  else
    raise "Export BUNDLE_GEMFILE=gemfiles/rails... explicitly"
  end
end

def example_path
  if rails_version = ENV['BUNDLE_GEMFILE'].to_s.match(/rails_\d+/)
    File.expand_path("../../../tmp/lurker_app_#{rails_version}", __FILE__)
  else
    raise "Export BUNDLE_GEMFILE=gemfiles/rails... explicitly"
  end
end

require 'fileutils'
require 'aruba/cucumber'

require 'rspec/expectations'
World(RSpec::Matchers)

require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'
require 'webdrivers/chromedriver'
require "#{example_path}/config/environment"
require 'database_cleaner'
require 'database_cleaner/cucumber'

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  Selenium::WebDriver.logger.level = :debug if ENV['CAPYBARA_DEBUG'].present?
  browser_capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(loggingPrefs: { browser: 'ALL' })
  browser_options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu no-sandbox disable-dev-shm-usage window-size=1900,1080])
  browser_options.add_argument('--ignore-certificate-errors')
  # Disable w3c mode (default as of Chrome 75) to allow for logging
  browser_options.add_option(:w3c, false)
  Capybara::Selenium::Driver.new app,
                                 browser: :chrome,
                                 options: browser_options,
                                 desired_capabilities: browser_capabilities
end

Capybara.app = Rails.application
Capybara.javascript_driver = ENV['CAPYBARA_JS_DRIVER']&.to_sym || :headless_chrome

DatabaseCleaner.strategy = :truncation

# otherwise it cleans up all rails folder
# https://github.com/cucumber/aruba/blob/bf612766ac51e28ca354e735980cd8a5d7eb296f/lib/aruba/setup.rb#L27L31
# it force deletes the working_directory,
# but it has to be working_directory to cd in and run `bin/rspec`
# this forces @no-clobber everywhere
# use CLEAN=1 env var to clean proper places
module ArubaSetupNoClobber
  def working_directory(clobber = true)
    super(false)
  end
end
Aruba::Setup.prepend(ArubaSetupNoClobber)

# see: https://github.com/colszowka/simplecov/issues/234
Aruba.configure do |config|
  config.working_directory = relative_example_path # Aruba::Contracts::RelativePath
  config.activate_announcer_on_command_failure = [:stdout]
  config.before :command do |cmd|
    set_environment_variable 'SIMPLECOV_CMDNAME', Digest::MD5.hexdigest(cmd.object_id.to_s)
    set_environment_variable 'SIMPLECOV_ROOT',    File.expand_path('../../..', __FILE__)
  end
end

Before do
  @dirs = [example_path]
  @aruba_timeout_seconds = 30
  DatabaseCleaner.start
  if ENV['CLEAN']
    system "bin/spring stop"
    %w[lurker public/lurker spec/requests spec/controllers].each do |dir_name|
      in_current_directory { remove(dir_name, force: true) }
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
