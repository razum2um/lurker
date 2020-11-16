# This is initial testing/demo rails app template (passed to `rails new`)

gem 'rack-cors', require: 'rack/cors'
gem 'rspec-rails'
gem 'spring-commands-rspec'
gem 'database_cleaner'
gem 'simplecov', '~> 0.7.1', require: false
gem 'kramdown',  '~> 1.3'
gem 'pdfkit', '~> 0.5'
gem 'wkhtmltopdf-binary', '~> 0.9'
gem 'execjs'
gem 'coderay'

unless ENV['TRAVIS']
  gem 'pry-byebug'
end

gem 'unicorn', group: :production

append_to_file 'Gemfile' do
  gem = if ENV['TRAVIS']
    "gem 'lurker', github: 'razum2um/lurker', branch: 'master'"
  else
    origin = `cd ../.. && git config --get remote.origin.url`.scan(/github\.com.(.*).git/).flatten.first.strip rescue 'razum2um/lurker'
    branch = `cd ../.. && git rev-parse --abbrev-ref HEAD`.strip rescue 'master'
    "gem 'lurker', github: '#{origin}', branch: '#{branch}'"
  end

  <<-CODE

    # new line above is important, branch is also important
    # please, dont commit here: "gem 'lurker', path: '../../'"
    # as I deploy this app instantly with this Gemfile
    #{gem}
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

