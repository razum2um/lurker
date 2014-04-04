file '.bundle/config', <<-CODE
---
BUNDLE_PATH: #{File.expand_path '../../vendor/bundle', __FILE__}
CODE

gem 'inherited_resources'
gem 'rspec-rails'

# comment_lines 'Gemfile', /spring/
gem 'spring-commands-rspec'

