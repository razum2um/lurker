require 'simplecov'
SimpleCov.start

require 'fileutils'
require 'aruba/cucumber'

require 'rspec/expectations'
World(RSpec::Matchers)

require 'capybara'
require 'capybara/dsl'
require 'capybara/cucumber'
require File.expand_path('../../../tmp/example_app/config/environment', __FILE__)

Capybara.app = Rails.application

begin
  require 'selenium-webdriver'
  # sorry for such a debug
  if File.exists?(ff = '/opt/homebrew-cask/Caskroom/firefox/latest/Firefox.app/Contents/MacOS/firefox')
    Selenium::WebDriver::Firefox::Binary.path = ff
  end
rescue LoadError
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
end

# see: https://github.com/colszowka/simplecov/issues/234
Aruba.configure do |config|
  config.before_cmd do |cmd|
    set_env 'SIMPLECOV_CMDNAME', Digest::MD5.hexdigest(cmd)
    set_env 'SIMPLECOV_ROOT',    File.expand_path('../../..', __FILE__)
  end
end

Before do
  @dirs = ["tmp/example_app"]
  @aruba_timeout_seconds = 30
end
