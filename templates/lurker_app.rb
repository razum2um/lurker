gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'database_cleaner'
gem 'simplecov', '~> 0.7.1', require: false
gem 'pry-debugger', require: false
gem 'pry-stack_explorer', require: false
gem 'unicorn', group: :production

append_to_file 'Gemfile' do
  <<-CODE

    # new line above is important
    lurker_file = File.expand_path('../../../lib/lurker.rb', __FILE__)
    if File.exists?(lurker_file)
      # run within specs
      gem 'lurker', '~> 0', path: "#{File.expand_path('../../../lurker', __FILE__)}"
    else
      # run at heroku
      gem 'lurker', github: 'razum2um/lurker', branch: 'master'
    end
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
