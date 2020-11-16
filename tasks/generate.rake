def rails_version
  if (version = ENV['BUNDLE_GEMFILE'].to_s.match(/rails_\d+/)&.to_a&.last)
    Gem::Version.new(version)
  end
end

TEMPLATE_TASK = rails_version >= Gem::Version.new('5.0') ? 'app:template' : 'rails:template'
TASK_RUNNER = rails_version >= Gem::Version.new('5.0') ? 'bin/rails' : 'bin/rake'

if rails_version
  EXAMPLE_APP = "tmp/lurker_app_#{rails_version}"
else
  raise "Export BUNDLE_GEMFILE=gemfiles/rails_... explicitly"
end

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
      in_lurker_app "bundle config --local local.lurker $PWD/../.." unless ENV['CI']
      in_lurker_app "bundle config --local set without 'development'"
      in_lurker_app "bundle install"
      %w[rake rspec-core spring bundler].each do |gem|
        in_lurker_app "bundle binstubs #{gem} --force"
      end
    end
  end

  desc "generate a bunch of stuff with generators"
  task :stuff do
    in_lurker_app "LOCATION='../../templates/generate_stuff.rb' #{TASK_RUNNER} #{TEMPLATE_TASK}"

    if ENV['CI']
      in_lurker_app "#{TASK_RUNNER} RAILS_ENV=test db:setup "
    else
      in_lurker_app "#{TASK_RUNNER} db:setup"
      in_lurker_app "#{TASK_RUNNER} db:import"
    end
  end
end

def in_lurker_app(command)
  FileUtils.mkdir_p(EXAMPLE_PATH)
  Dir.chdir(EXAMPLE_PATH) do
    bundler_method = Bundler.respond_to?(:with_unbundled_env) ? :with_unbundled_env : :with_clean_env
    Bundler.send(bundler_method) do
      sh command
    end
  end
end

def needs_generation?
  !File.exists?("#{EXAMPLE_PATH}/Gemfile")
end

def place_github_badge(fname)
  full_fname = "#{EXAMPLE_PATH}/#{fname}"
  content = File.read(full_fname).gsub("</header>", <<-EOF
    </header>
    <a href='https://github.com/razum2um/lurker'>
      <img style='position: absolute; top: 0; right: 0; border: 0; z-index: 1000'
           src="https://camo.githubusercontent.com/365986a132ccd6a44c23a9169022c0b5c890c387/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f7265645f6161303030302e706e67"
           data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_red_aa0000.png"
           alt='Fork me on GitHub'>
    </a>
    EOF
    )
  File.open(full_fname, 'w') { |f| f.write content }
end

desc 'destroys & recreates new test app'
task :regenerate => ["clobber:coverage", "clobber:app", "assets:precompile", "generate:app", "generate:stuff"]

desc 'run cucumber in a fresh env'
task :features => [:regenerate, :cucumber]

desc 'convert docs for example app, prepages gh-pages, having schemas in /lurker'
task :convert_example_docs do
  in_lurker_app "bin/lurker init_docs"

  if File.exists?(readme = File.expand_path('../../README.md', __FILE__))
    in_lurker_app "bin/lurker convert -c #{readme}"
  else
    in_lurker_app "bin/lurker convert"
  end

  place_github_badge 'public/lurker/index.html'
  in_lurker_app "bin/lurker convert -f pdf"
end

task :build_example_docs => [:features, :convert_example_docs]

