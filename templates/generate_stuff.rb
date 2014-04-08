gsub_file 'config/database.yml', /database: db\/development\.sqlite3/, 'database: db/test.sqlite3'
create_link "bin/lurker", "#{File.expand_path '../../bin/lurker', __FILE__}"

generate 'rspec:install'
generate 'model User name:string --no-timestamps --no-test-framework'
generate 'model Repo user:references name:string --no-timestamps --no-test-framework'

route <<-ROUTE
  namespace :api do
    namespace :v1 do
      resources :users do
        resources :repos
      end
    end
  end
ROUTE

inject_into_class 'app/models/user.rb', 'User' do
  <<-CODE
    has_many :repos
    validates :name, presence: true
  CODE
end

file 'app/controllers/application_controller.rb', 'ApplicationController', force: true do
  <<-CODE
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session
      before_filter :set_format

      private

      def set_format
        request.format = :json
      end
    end
  CODE
end

file 'app/controllers/api/v1/users_controller.rb', 'Api::V1::UsersController' do
  <<-CODE
    class Api::V1::UsersController < ApplicationController
      def index
        render json: User.all
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user
        else
          render json: { errors: @user.errors }
        end
      end

      def show
        render json: User.find(params[:id])
      end

      def destroy
        User.find(params[:id]).destroy
        render head: :ok
      end

      private

      def user_params
        @user_params = params[:user]
        if @user_params.respond_to? :permit
          @user_params.permit(:name)
        else
          @user_params
        end
      end
    end
  CODE
end

file 'app/controllers/api/v1/repos_controller.rb', 'Api::V1::ReposController' do
  <<-CODE
    class Api::V1::ReposController < ApplicationController

      def index
        render json: user.repos
      end

      def create
        @repo = user.repos.build(repo_params)
        if @repo.save
          render json: @repo
        else
          render json: { errors: @repo.errors }, status: 401
        end
      end

      def show
        render json: Repo.find(params[:id])
      end

      def destroy
        Repo.find(params[:id]).destroy
        render head: :ok
      end

      private

      def user
        @user ||= User.find(params[:user_id])
      end

      def repo_params
        @repo_params = params[:repo]
        if @repo_params.respond_to? :permit
          @repo_params.permit(:name, :user_id)
        else
          @repo_params
        end
      end
    end
  CODE
end

# FIXME: uninitialized constant User (NameError) in last creation line
append_to_file 'config/environment.rb' do
  <<-CODE
    $:.unshift File.expand_path('../../app/models', __FILE__)
  CODE
end

inject_into_class 'config/application.rb', 'Application' do
  <<-CODE
    config.middleware.use Lurker::Sandbox
  CODE
end

prepend_to_file 'spec/spec_helper.rb' do
  <<-CODE
  require 'simplecov'

  if simplecov_root = ENV['SIMPLECOV_ROOT']
    SimpleCov.root simplecov_root
  end

  if simplecov_cmdname = ENV['SIMPLECOV_CMDNAME']
    SimpleCov.command_name simplecov_cmdname
    SimpleCov.start do
      filters.clear # This will remove the :root_filter that comes via simplecov's defaults
      add_filter do |src|
        !(src.filename =~ /^\#{SimpleCov.root}\\/lib\\/lurker/)
      end
    end
  else
    SimpleCov.start
  end

  CODE
end

file 'spec/support/fixme.rb', <<-CODE
  require 'lurker/spec_watcher'
  RSpec.configure do |c|
    c.treat_symbols_as_metadata_keys_with_true_values = true
    c.backtrace_exclusion_patterns += [
      /\\/lib\\/lurker/
    ]
  end
CODE

run 'rake db:migrate'
