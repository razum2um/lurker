source 'https://rubygems.org'
gemspec

group :development do
  # tools
  gem 'pry-byebug', platforms: [:mri_20, :mri_21, :mri_22]
  gem 'pry-debugger', platforms: :mri_19
  gem 'pry-stack_explorer', platform: :mri
  gem 'pry-session', platform: :mri
  # rspec --format fuubar
  gem 'fuubar'
  # cucumber --format fuubar
  gem 'fuubar-cucumber'
  gem 'selenium-webdriver'

  # deploy site
  gem 'highline'
  # gem 'coderay', path: '../coderay'

  # multiple rails versions support
  gem 'appraisal', github: 'razum2um/appraisal', branch: 'master'

  # build template static
  # run `rake assets:precompile`
  # to get bundled application.(js|css)
  gem 'sprockets'
  gem 'uglifier'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'bootstrap-sass', '~> 3.1.1'
  gem 'jquery-rails'
  gem 'remotipart'
  gem 'launchy'
end

