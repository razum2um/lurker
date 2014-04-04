file '.bundle/config', <<-CODE
---
BUNDLE_PATH: #{File.expand_path '../../vendor/bundle', __FILE__}
CODE

gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'lurker', github: 'razum2um/lurker', branch: 'master', require: 'lurker/server'

