ENV['RAILS_ENV'] = 'test'
require 'bundler/setup'
require 'lurker'

require 'simplecov'
SimpleCov.start do
  filters.clear # This will remove the :root_filter that comes via simplecov's defaults
  add_filter do |src|
    # WTF??? if erb_schema_context gets into .resultset.json second time
    # coveralls WONT calculate overall coverage... o_O
    src.filename =~ /erb_schema_context/ || !(src.filename =~ /^#{SimpleCov.root}\/lib\/lurker/)
  end
end

Dir[File.expand_path '../support/**/*.rb', __FILE__].each { |file| require file }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end
