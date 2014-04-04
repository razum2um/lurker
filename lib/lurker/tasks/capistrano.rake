namespace :deploy do

  desc 'Runs rake db:migrate if migrations are set'
  task :generate_lurker do
    on roles(:web) do
      within release_path do
        lurker_path = 'lurker'
        execute :bundle, %Q{exec lurker convert lurker --output=./public/#{lurker_path} -u "/#{lurker_path}"}
      end
    end
  end

  after :finishing, 'deploy:generate_lurker'
end
