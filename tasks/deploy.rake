GH_PAGES    = 'gh-pages'

def on_razum2um_me(command)
  puts "About to run: #{command}"
  system %Q{ssh lurker@razum2um.me 'bash -l -c "source ~/.bashrc; cd ~/lurker; rvm use 2.1.1; #{command}"'}
end

def in_gh_pages(command)
  FileUtils.mkdir_p(GH_PAGES)
  Dir.chdir(GH_PAGES) do
    Bundler.with_clean_env do
      sh command
    end
  end
end

def ask_for_deploy(name, callback)
  if ENV['FORCE_DEPLOY']
    puts "Deploy to #{name}"
    callback.call
  else
    require 'highline/import'
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
      in_lurker_app "heroku run rake db:import --app lurker-app" rescue nil
    }
    ask_for_deploy("heroku", do_deploy)
  end

  desc 'rebuilds & pushes app to heroku'
  task :deploy => [:prepull, :build_example_docs, 'heroku:push'] do
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
      on_razum2um_me "RAILS_ENV=production bin/rake db:migrateRAILS_ENV=production bin/rake db:migrate"
      on_razum2um_me "RAILS_ENV=production bin/rake db:import"
      on_razum2um_me "touch tmp/restart.txt"
    }
    ask_for_deploy("razum2um.me", do_deploy)
  end

  desc 'rebuilds & pushes app to razum2um.me'
  task :deploy => [:prepull, :build_example_docs, 'razum2um:push'] do
  end
end

namespace :github do
  desc 'copies htmls from deployed app'
  task :copy_html do
    if File.exists?(pages = File.expand_path('../../gh-pages', __FILE__))
      in_lurker_app "cp -R public/lurker/* #{pages}"
    end
  end

  desc 'pushes example lurker_app to gh-pages'
  task :push => :copy_html do
    do_deploy = Proc.new {
      in_gh_pages "git commit -a -m 'auto commit: #{`git log --oneline -n 1`.strip}'" rescue nil
      in_gh_pages "git push origin gh-pages"
    }
    in_gh_pages "git add -A"
    in_gh_pages "git status"
    ask_for_deploy("gh-pages", do_deploy)
  end

  desc 'rebuilds & pushes app to gh-pages'
  task :deploy => [:prepull, :build_example_docs, 'github:push'] do
  end
end

desc 'pulls if lurker app is empty'
task :prepull do
  unless File.exists?("#{EXAMPLE_PATH}/.git")
    sh "git clone git@heroku.com:lurker-app.git #{EXAMPLE_APP}"
    in_lurker_app "git remote add razum2um lurker@lurker.razum2um.me:~/git"
  end
  unless File.exists?(File.expand_path("../../#{GH_PAGES}/.git", __FILE__))
    sh "git clone git@github.com:razum2um/lurker.git #{GH_PAGES}"
    in_gh_pages "git checkout gh-pages"
  end
end

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

