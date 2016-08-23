source 'https://rubygems.org'
gemspec

# these gems are needed while cucumber runs
gem 'pg', '~> 0.18'
gem 'kramdown', '~> 1.3'
gem 'diffy', '~> 3.0'
gem 'execjs', '~> 2.0'
gem 'pdfkit', '~> 0.6'
gem 'wkhtmltopdf-binary', '~> 0.9'

group :development, :test do
  # tools (MRI without 1.9)
  platforms :mri_20, :mri_21, :mri_22, :mri_23 do
    gem 'pry-byebug'
    gem 'pry-stack_explorer'
    gem 'pry-session'
  end

  # rspec --format fuubar
  gem 'fuubar'
  # cucumber --format fuubar
  gem 'fuubar-cucumber'
  gem 'selenium-webdriver'

  # deploy site
  gem 'highline'
  # gem 'coderay', path: '../coderay'

  # multiple rails versions support
  gem 'appraisal'

  # build template static
  # run `rake assets:precompile`
  # to get bundled application.(js|css)
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'bootstrap-sass', '~> 3.3.3'
  gem 'jquery-rails'
  # gem 'remotipart'
  gem 'launchy'
end

