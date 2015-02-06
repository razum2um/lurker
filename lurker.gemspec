# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lurker/version"

Gem::Specification.new do |spec|
  spec.name          = "lurker"
  spec.version       = Lurker::VERSION
  spec.authors       = ["Vlad Bokov", "Sergey Fedorov"]
  spec.email         = ["bokov.vlad@gmail.com", "oni.strech@gmail.com"]
  spec.summary       = %q{Get pretty, documented and visible API}
  spec.description   = %q{The new de-facto for API testing your Rails application}
  spec.homepage      = "http://github.com/razum2um/lurker"
  spec.license       = "MIT"
  spec.cert_chain    = ['certs/razum2um.pem']
  spec.signing_key   = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("json", "~> 1.7")
  spec.add_dependency("json-schema", "~> 2.2")
  spec.add_dependency("thor", "~> 0.19")
  spec.add_dependency("sinatra", "~> 1.4")
  spec.add_dependency("hashie", ">= 3.0")
  spec.add_dependency("activesupport", ">= 3.2", "< 4.3")

  # testing
  spec.add_development_dependency("psych", "~> 2.0")
  spec.add_development_dependency("bundler", "~> 1.7.11")
  spec.add_development_dependency("rack-cors", "~> 0.2")
  spec.add_development_dependency("rails", ">= 3.2", "< 4.3")
  spec.add_development_dependency("rake", "~> 10.2")
  spec.add_development_dependency("rspec", "~> 2.14")
  spec.add_development_dependency("cucumber", "~> 1.3")
  spec.add_development_dependency("aruba", "~> 0.5")
  spec.add_development_dependency("capybara", "~> 2.2")
  spec.add_development_dependency("nokogiri", "~> 1.5")
  spec.add_development_dependency("poltergeist", "~> 1.5")
  spec.add_development_dependency("database_cleaner", "~> 1.2")

  spec.add_development_dependency("simplecov", "~> 0.7")
  spec.add_development_dependency("coveralls", "~> 0.7")
  spec.add_development_dependency("rubocop", "~> 0.21")

  # FIXME: these gems are needed while cucumber runs
  # inner Gemfile isn"t getting used, but lib"s one
  spec.add_development_dependency("rspec-rails", "~> 2.14")
  spec.add_development_dependency("pg", "~> 0.16")
  spec.add_development_dependency("kramdown", "~> 1.3")
  spec.add_development_dependency("diffy", "~> 3.0")
  spec.add_development_dependency("execjs", "~> 2.0")
  spec.add_development_dependency("pdfkit", "~> 0.6")
  spec.add_development_dependency("wkhtmltopdf-binary", "~> 0.9")

  if RUBY_VERSION >= "2.2.0"
    # FIXME : this gem are needed to ruby 2.2.0
    spec.add_development_dependency("test-unit", "~> 3.0")
  end
end

