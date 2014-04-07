require 'simplecov'
SimpleCov.start

require 'aruba/cucumber'

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
