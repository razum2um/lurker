file '.bundle/config', <<-CODE
---
BUNDLE_PATH: #{File.expand_path '../../vendor/bundle', __FILE__}
CODE

gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'simplecov', '~> 0.7.1', require: false
gem 'pry-debugger', require: false
gem 'pry-stack_explorer', require: false
gem 'lurker', github: 'razum2um/lurker', branch: 'master', require: 'lurker/server'

