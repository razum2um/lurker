file '.bundle/config', <<-CODE
---
BUNDLE_PATH: #{File.expand_path '../../vendor/bundle', __FILE__}
CODE

gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'simplecov', '~> 0.7.1', require: false
gem 'pry-debugger', require: false
gem 'pry-stack_explorer', require: false

append_to_file 'Gemfile' do
  <<-CODE

    if File.exists?(File.expand_path('../../../lurker.rb', __FILE__))
      # run within specs
      gem 'lurker', path: "#{File.expand_path('../../..', __FILE__)}"
    else
      # run at heroku
      gem 'lurker', github: 'razum2um/lurker', branch: 'master'
    end
  CODE
end
