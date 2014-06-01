EXAMPLE_APP = 'tmp/lurker_app'
EXAMPLE_PATH = File.expand_path("../../#{EXAMPLE_APP}", __FILE__)

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
      sh "bundle exec rails new #{EXAMPLE_APP} -d postgresql -m #{File.expand_path '../../templates/lurker_app.rb', __FILE__} --skip-javascript --skip-git --skip-test-unit --skip-keeps --skip-bundle --quiet"
      in_lurker_app "bundle config --local local.lurker $PWD/../.." unless ENV['TRAVIS']
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
  FileUtils.mkdir_p(EXAMPLE_PATH)
  Dir.chdir(EXAMPLE_PATH) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

def needs_generation?
  !File.exists?("#{EXAMPLE_PATH}/Gemfile")
end

desc 'destroys & recreates new test app'
task :regenerate => ["clobber:coverage", "clobber:app", "generate:app", "generate:stuff"]

desc 'run cucumber in a fresh env'
task :features => [:regenerate, :cucumber]

desc 'convert docs for example app, prepages gh-pages'
task :build_example_docs => :features do
  if File.exists?(readme = File.expand_path('../../README.md', __FILE__))
    in_lurker_app "bin/lurker convert -c #{readme}"
  else
    in_lurker_app "bin/lurker convert"
  end

  in_lurker_app %Q{sed -i "" "s|</header>|</header><a href='https://github.com/razum2um/lurker'><img style='position: absolute; top: 0; right: 0; border: 0; z-index: 1000' src='https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png' alt='Fork me on GitHub'></a>|" html/index.html}
  in_lurker_app "bin/lurker convert -f pdf -o html"
end

