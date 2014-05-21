# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lurker/version"

Gem::Specification.new do |spec|
  spec.name          = "lurker"
  spec.version       = Lurker::VERSION
  spec.authors       = ["Vlad Bokov"]
  spec.email         = ["razum2um@mail.ru"]
  spec.summary       = %q{Lukrs into your API rquest to tell you the truth.}
  spec.description   = %q{It hooks in rspec controller methods to check theirs schema and let people try it}
  spec.homepage      = "http://github.com/razum2um/lurker"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency("json", "~> 1.7")
  spec.add_dependency("json-schema", "~> 2.2")
  spec.add_dependency("thor", "~> 0.19")
  spec.add_dependency("sinatra", "~> 1.4")
  spec.add_dependency("hashie", "~> 2.0")

  # testing
  spec.add_development_dependency("psych", "~> 2.0")
  spec.add_development_dependency("bundler", "~> 1.3")
  spec.add_development_dependency("rack-cors", "~> 0.2")
  spec.add_development_dependency("rails", ">= 3.2", "< 4.2")
  spec.add_development_dependency("rake", "~> 10.2")
  spec.add_development_dependency("rspec", "~> 2.14")
  spec.add_development_dependency("cucumber", "~> 1.3")
  spec.add_development_dependency("aruba", "~> 0.5")
  spec.add_development_dependency("capybara", "~> 2.2")
  spec.add_development_dependency("nokogiri", "~> 1.5.11")
  spec.add_development_dependency("poltergeist", "~> 1.5")
  spec.add_development_dependency("database_cleaner", "~> 1.2")

  spec.add_development_dependency("simplecov", "~> 0.7")
  spec.add_development_dependency("coveralls", "~> 0.7")
  spec.add_development_dependency("rubocop", "~> 0.21")

  # FIXME: these gems are needed while cucumber runs
  # inner Gemfile isn"t getting used, but lib"s one
  spec.add_development_dependency("rspec-rails", "~> 2.14")
  spec.add_development_dependency("pg", "~> 0.16")
end
