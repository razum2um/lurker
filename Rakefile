require "bundler/gem_tasks"
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'coveralls/rake/task'

desc 'pry console for gem'
task :c do
  require 'pry'
  require 'lurker'
  require 'lurker/cli'
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
    %w[fonts bootstrap.css.map].each do |subdir|
      FileUtils.cp_r(SOURCE_DIR.join(subdir), BUILD_DIR)
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

    sprockets.js_compressor  = :uglify
    sprockets.css_compressor  = :scss

    BUNDLES.each do |bundle|
      assets = sprockets.find_asset(bundle)
      realname = (assets.pathname.basename.to_s.split(".").take_while { |s| !s.match /^(js|css)$/ } + [$~.to_s]).join(".")
      assets.write_to(BUILD_DIR.join(realname))
    end
  end
end

# testing

ENV['COVERALLS_NOISY'] = '1'
Coveralls::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format progress"
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = "features --format progress --tags ~@wip"
end

EXAMPLE_APP = 'tmp/lurker_app'
GH_PAGES    = 'gh-pages'
EXAMPLE_PATH = File.expand_path("../#{EXAMPLE_APP}", __FILE__)

namespace :clobber do
  desc "clobber coverage"
  task :coverage do
    rm_rf File.expand_path('../coverage', __FILE__)
  end

  desc "clobber the generated app"
  task :app do
    FileUtils.mkdir_p EXAMPLE_PATH
    in_lurker_app "bin/spring stop" rescue nil
    Dir.chdir EXAMPLE_PATH do
      Dir.glob("*", File::FNM_DOTMATCH).each do |fname|
        next if fname == '.' || fname == '..' || fname == '.git' || fname == '.bundle'
        FileUtils.rm_rf fname
      end
    end
  end
end

namespace :generate do
  desc "generate a fresh app with rspec installed"
  task :app do |t|
    if needs_generation?
      sh "bundle exec rails new #{EXAMPLE_APP} -d postgresql -m #{File.expand_path '../templates/lurker_app.rb', __FILE__} --skip-javascript --skip-git --skip-test-unit --skip-keeps --skip-bundle --quiet"
      in_lurker_app "bundle config --local local.lurker $PWD/../.."
      in_lurker_app "bundle install"
      %w[rake rspec-core spring].each do |gem|
        in_lurker_app "bundle binstubs #{gem}"
      end
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_lurker_app "LOCATION='../../templates/generate_stuff.rb' bin/rake rails:template --quiet --silent"

    unless ENV['TRAVIS']
      in_lurker_app 'bin/rake db:setup'
      in_lurker_app 'bin/rake db:import'
    end
    in_lurker_app 'bin/rake RAILS_ENV=test db:setup'
  end
end

def in_lurker_app(command)
  Dir.chdir(EXAMPLE_PATH) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

def in_gh_pages(command)
  Dir.chdir(GH_PAGES) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

def on_razum2um_me(command)
  puts "About to run: #{command}"
  system %Q{ssh lurker@razum2um.me 'bash -l -c "source ~/.bashrc; cd ~/lurker; rvm use 2.1.1; #{command}"'}
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

desc 'convert docs for example app, prepages gh-pages'
task :build_example_docs => :features do
  if File.exists? '../README.md'
    in_lurker_app "bin/lurker convert -c #{File.expand_path('../README.md', __FILE__)}"
  else
    in_lurker_app "bin/lurker convert"
  end

  in_lurker_app "bin/lurker convert -f pdf -o html"

  if File.exists? '../../gh-pages'
    in_lurker_app "cp -R html/* ../../gh-pages"
  end
end

def ask_for_deploy(name, callback)
  if ENV['FORCE_DEPLOY']
    puts "Deploy to #{name}"
    callback.call
  else
    require_with_help 'highline/import'
    choose do |menu|
      menu.prompt = "Commit & push & deploy to #{name}?"
      menu.choice(:yes) {
        ENV['FORCE_DEPLOY'] = '1'
        callback.call
      }
      menu.choice(:no) { say("Exit") }
    end
  end
end

namespace :heroku do
  desc 'pushes example lurker_app to heroku'
  task :push => :predeploy do
    do_deploy = Proc.new {
      in_lurker_app "git commit -a -m 'auto commit: #{`git log --oneline -n 1`.strip}'" rescue nil
      in_lurker_app "git push origin master"
      in_lurker_app "heroku run rake db:import --app lurker-app"
    }
    ask_for_deploy("heroku", do_deploy)
  end

  desc 'rebuilds & pushes app to heroku'
  task :deploy => [:build_example_docs, 'heroku:push'] do
  end
end

namespace :razum2um do
  desc 'pushes example lurker_app to razum2um'
  task :push => :predeploy do
    do_deploy = Proc.new {
      in_lurker_app "git commit -a -m 'auto commit: #{`git log --oneline -n 1`.strip}'" rescue nil
      in_lurker_app "git push razum2um master"
      %w[database secrets].each do |fname|
        on_razum2um_me "cp ~/#{fname}.yml config/#{fname}.yml"
      end
      on_razum2um_me "bundle install"
      on_razum2um_me "RAILS_ENV=production bin/rake db:migrate"
      on_razum2um_me "RAILS_ENV=production bin/rake db:import"
      on_razum2um_me "touch tmp/restart.txt"
    }
    ask_for_deploy("razum2um.me", do_deploy)
  end

  desc 'rebuilds & pushes app to razum2um.me'
  task :deploy => [:build_example_docs, 'razum2um:push'] do
  end
end

namespace :github do
  desc 'pushes example lurker_app to gh-pages'
  task :push do
    do_deploy = Proc.new {
      in_gh_pages "git commit -a -m 'auto commit: #{`git log --oneline -n 1`.strip}'" rescue nil
      in_gh_pages "git push origin gh-pages"
    }
    in_gh_pages "git add -A"
    in_gh_pages "git status"
    ask_for_deploy("gh-pages", do_deploy)
  end

  desc 'rebuilds & pushes app to gh-pages'
  task :deploy => [:build_example_docs, 'github:push'] do
  end
end

task :default => ["clobber:coverage", :spec, :regenerate, :cucumber, 'coveralls:push']

desc 'commits lurker app'
task :predeploy do
  do_predeploy = Proc.new {
    in_lurker_app "echo 'bin/lurker' > .gitignore"
    in_lurker_app "echo 'log' >> .gitignore"
    # commit migration and deploy by hand first time
    in_lurker_app "echo 'db/*' >> .gitignore"
    in_lurker_app "echo 'tmp/*log' >> .gitignore"
    in_lurker_app "echo '.bundle/*' >> .gitignore"

    in_lurker_app "git add -A"
    in_lurker_app "git status"
  }

  if (stage = `git log @{u}..`).lines.size > 0
    puts stage
    do_push_and_predeploy = Proc.new {
      sh "git push origin master"
      do_predeploy.call
    }
    ask_for_deploy("push master", do_push_and_predeploy)
  else
    do_predeploy.call
  end
end

desc 'deploys everything'
task :deploy => ["razum2um:deploy", "heroku:deploy", "github:deploy"]

desc 'pushes everything'
task :push => ["razum2um:push", "heroku:push", "github:push"]

desc 'releases gem & updates docs'
task :publish do
  require 'lurker'
  version = Lurker::VERSION

  Bundler.with_clean_env do
    system "git tag v#{version}"
    system "relish versions:add razum2um/lurker:#{version}"
    system "relish push razum2um/lurker:#{version}"
    system "gem build lurker.gemspec --sign"
    system "git push --tags"
    system "gem push lurker-#{version}.gem"
  end
end

