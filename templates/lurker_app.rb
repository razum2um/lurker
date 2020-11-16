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

unless ENV['CI']
  gem 'pry-byebug'
end

append_to_file 'Gemfile' do
  gem = if ENV['CI']
    branch = %x[git branch --show-current]
    "gem 'lurker', github: 'razum2um/lurker', branch: '#{branch.strip}'"
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

file 'Procfile' do
  <<-CODE
    web: bundle exec puma -p $PORT
  CODE
end

gsub_file('Gemfile', /gem.*tzinfo-data.*/, '')
