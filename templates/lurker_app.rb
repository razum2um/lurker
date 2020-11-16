# This is initial testing/demo rails app template (passed to `rails new`)

gem 'rack-cors', require: 'rack/cors'
gem 'rspec-rails', group: [:development, :test]
gem 'spring-commands-rspec', group: [:development, :test]
gem 'database_cleaner', group: [:development, :test]
gem 'simplecov', '~> 0.7.1', require: false
gem 'kramdown',  '~> 1.3', group: [:development, :test]
gem 'pdfkit', '~> 0.5', group: [:development, :test]
gem 'wkhtmltopdf-binary', '~> 0.9', group: [:development, :test]
gem 'execjs', group: [:development, :test]
gem 'coderay', group: [:development, :test]

unless ENV['CI']
  gem 'pry-byebug', group: [:development, :test]
end

append_to_file 'Gemfile' do
  gem = if ENV['CI']
    branch = ENV['TRAVIS_BRANCH'] || %x[git branch --show-current]
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

# docker needs with for mri too
gsub_file('Gemfile', /gem.*tzinfo-data.*/, 'gem "tzinfo-data"')
