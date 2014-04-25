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
    require 'pathname'
    require 'logger'
    require 'fileutils'

    require 'lurker/cli'

    require_with_help 'sprockets'
    require_with_help 'sass'

    ROOT        = Pathname(File.dirname(__FILE__))
    LOGGER      = Logger.new(STDOUT)
    BUNDLES     = %w( application.css application.js )
    BUILD_DIR   = Pathname.new Lurker::Cli.precompiled_static_root
    SOURCE_DIR  = Pathname.new Lurker::Cli.source_root

    FileUtils.rm_rf(BUILD_DIR)
    FileUtils.mkdir_p(BUILD_DIR)

    # raw copy
    %w[fonts].each do |subdir|
      FileUtils.cp_r(SOURCE_DIR.join(subdir), BUILD_DIR.join(subdir))
    end

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

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format progress"
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "features --format progress --tags ~@wip"
end

EXAMPLE_APP = 'tmp/lurker_app'
EXAMPLE_PATH = File.expand_path("../#{EXAMPLE_APP}", __FILE__)

namespace :clobber do
  desc "clobber coverage"
  task :coverage do
    rm_rf File.expand_path('../coverage', __FILE__)
  end

  desc "clobber the generated app"
  task :app do
    FileUtils.mkdir_p EXAMPLE_PATH
    in_lurker_app "bin/spring stop" if File.exist?("#{EXAMPLE_PATH}/bin/spring")
    Dir.chdir EXAMPLE_PATH do
      Dir.glob("*", File::FNM_DOTMATCH).each do |fname|
        next if fname == '.' || fname == '..' || fname == '.git'
        FileUtils.rm_rf fname
      end
    end
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    if needs_generation?
      sh "bundle exec rails new #{EXAMPLE_APP} -d postgresql -m #{File.expand_path '../templates/lurker_app.rb', __FILE__} --skip-javascript --skip-sprockets --skip-git --skip-test-unit --skip-keeps --quiet"
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_lurker_app "LOCATION='../../templates/generate_stuff.rb' bin/rake rails:template --quiet --silent"
  end
end

def in_lurker_app(command)
  Dir.chdir(EXAMPLE_PATH) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

def needs_generation?
  !File.exists?("#{EXAMPLE_PATH}/Gemfile")
end

def require_with_help(name)
  begin
    require name
  rescue LoadError
    puts "Incorrect Gemfile, run: `bundle --gemfile Gemfile.local` and"
    puts "BUNDLE_GEMFILE=$PWD/Gemfile.local #{$0}"
    raise
  end
end

desc 'destroys & recreates new test app'
task :regenerate => ["clobber:coverage", "clobber:app", "generate:app", "generate:stuff"]

desc 'run cucumber in a fresh env'
task :features => [:regenerate, :cucumber]

desc 'convert docs for example app'
task :build_example_docs => :features do
  in_lurker_app "bin/lurker convert -c #{File.expand_path('../README.md', __FILE__)}"
end

namespace :heroku do
  desc 'pushes example lurker_app to heroku'
  task :push do
    require_with_help 'highline/import'

    in_lurker_app "echo 'bin/lurker' > .gitignore"
    in_lurker_app "echo 'log' >> .gitignore"
    # commit migration and deploy by hand first time
    in_lurker_app "echo 'db/*' >> .gitignore"
    in_lurker_app "echo 'tmp/*' >> .gitignore"


    in_lurker_app "git add -A"
    in_lurker_app "git status"
    choose do |menu|
      menu.prompt = 'Commit & push & deploy?'
      menu.choice(:yes) {
        in_lurker_app "git commit -a -m 'auto commit: #{`git log --oneline -n 1`.strip}'"
        in_lurker_app "git push origin master"
        in_lurker_app "heroku run rake db:import --app lurker-app"
      }
      menu.choice(:no) { say("Exit") }
    end
  end

  desc 'rebuilds & pushes app to heroku'
  task :deploy => [:build_example_docs, 'heroku:push'] do
  end
end

task :default => [:spec, :regenerate, :cucumber, 'coveralls:push']

