gem 'rack-cors', require: 'rack/cors'
gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'database_cleaner'
gem 'simplecov', '~> 0.7.1', require: false

unless ENV['TRAVIS']
  if RUBY_VERSION > '2.0.0'
    gem 'pry-byebug', group: [:development, :test]
  else
    gem 'pry-debugger', group: [:development, :test]
  end
  gem 'pry-stack_explorer', group: [:development, :test]
end

gem 'unicorn', group: :production
gem 'therubyracer', group: :production

append_to_file 'Gemfile' do
  <<-CODE

    # new line above is important
    gem 'lurker', github: 'razum2um/lurker', branch: 'master'
  CODE
end

file 'config/unicorn.rb' do
  <<-CODE
    worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
    timeout 15
    preload_app true

    before_fork do |server, worker|
      Signal.trap 'TERM' do
        puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
        Process.kill 'QUIT', Process.pid
      end

      defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
    end

    after_fork do |server, worker|
      Signal.trap 'TERM' do
        puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
      end

      defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
    end
  CODE
end

file 'Procfile' do
  <<-CODE
    web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
  CODE
end
