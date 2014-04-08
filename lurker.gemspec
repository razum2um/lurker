# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lurker/version'

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

  spec.add_dependency("json")
  spec.add_dependency("json-schema", "~> 2.2")
  spec.add_dependency("kramdown")
  spec.add_dependency("thor")
  spec.add_dependency("diffy")
  spec.add_dependency("sinatra")

  # testing
  spec.add_development_dependency("bundler", "~> 1.5")
  spec.add_development_dependency("rails", "~> 4.1.0.rc2")
  spec.add_development_dependency("rake")
  spec.add_development_dependency("rspec")
  spec.add_development_dependency("cucumber")
  spec.add_development_dependency("aruba")
  spec.add_development_dependency("capybara")
  spec.add_development_dependency("poltergeist")

  spec.add_development_dependency('simplecov', '~> 0.7.1')
  spec.add_development_dependency('coveralls')

  # FIXME: these gems are needed while cucumber runs
  # inner Gemfile isn't getting used, but lib's one
  spec.add_development_dependency("rspec-rails")
  spec.add_development_dependency("sqlite3")
end
