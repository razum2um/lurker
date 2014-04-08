require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

desc 'pry console for gem'
task :c do
  require 'pry'
  require 'lurker'
  ARGV.clear
  Pry.start
end

namespace :assets do
  desc 'compiles static css & js for web'
  task :precompile do
    begin
      require 'pathname'
      require 'logger'
      require 'fileutils'
      require 'sprockets'
      require 'sass'
    rescue LoadError
      puts 'Run this task as:'
      puts 'BUNDLE_GEMFILE=Gemfile.local rake assets:precompile'
      raise
    end

    ROOT        = Pathname(File.dirname(__FILE__))
    LOGGER      = Logger.new(STDOUT)
    BUNDLES     = %w( application.css application.js )
    BUILD_DIR   = ROOT.join("lib/lurker/templates/public")
    SOURCE_DIR  = ROOT.join("lib/lurker/templates")

    FileUtils.rm_rf(BUILD_DIR)
    FileUtils.mkdir_p(BUILD_DIR)

    sprockets = Sprockets::Environment.new(ROOT) do |env|
      env.logger = LOGGER
    end

    sprockets.context_class.class_eval do
      def asset_path(path, options = {})
        '/'
      end
    end

    sprockets.append_path(SOURCE_DIR.join('javascripts').to_s)
    sprockets.append_path(SOURCE_DIR.join('stylesheets').to_s)

    %w[jquery-rails bootstrap-sass remotipart].each do |gem|
      gem_path = Pathname.new(Bundler.rubygems.find_name(gem).first.full_gem_path)
      %w[javascripts stylesheets].each do |prefix|
        sprockets.append_path(gem_path.join('vendor', 'assets', prefix).to_s)
      end
    end

    BUNDLES.each do |bundle|
      assets = sprockets.find_asset(bundle)
      realname = (assets.pathname.basename.to_s.split(".").take_while { |s| !s.match /^(js|css)$/ } + [$~.to_s]).join(".")
      assets.write_to(BUILD_DIR.join(realname))
    end
  end
end

# testing

Coveralls::RakeTask.new
RSpec::Core::RakeTask.new(:spec)
Cucumber::Rake::Task.new(:cucumber)

EXAMPLE_PATH = './tmp/example_app'

namespace :clobber do
  desc "clobber coverage"
  task :coverage do
    rm_rf File.expand_path('../coverage', __FILE__)
  end

  desc "clobber the generated app"
  task :app do
    in_example_app "bin/spring stop" if File.exist?("#{EXAMPLE_PATH}/bin/spring")
    rm_rf EXAMPLE_PATH
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    unless File.directory?(EXAMPLE_PATH)
      sh "bundle exec rails new #{EXAMPLE_PATH} -m #{File.expand_path '../templates/example_app.rb', __FILE__} --skip-javascript --skip-sprockets --skip-git --skip-test-unit --skip-keeps --quiet"
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_example_app "LOCATION='../../templates/generate_stuff.rb' bin/rake rails:template --quiet --silent"
  end
end

def in_example_app(command)
  Dir.chdir(EXAMPLE_PATH) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

desc 'destroys & recreates new test app'
task :regenerate => ["clobber:coverage", "clobber:app", "generate:app", "generate:stuff"]

desc 'run cucumber in a fresh env'
task :features => [:regenerate, :cucumber]

task :default => [:spec, :regenerate, :cucumber, 'coveralls:push']

