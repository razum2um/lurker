require 'aruba/cucumber'

Before do
  @dirs = ["tmp/example_app"]
end

#ENV['PATH'] = "#{File.expand_path('../tmp/example_app', __FILE__)}#{File::PATH_SEPARATOR}#{ENV['PATH']}"
#ENV['BUNDLE_GEMFILE'] = File.expand_path('../tmp/example_app/Gemfile', __FILE__)
