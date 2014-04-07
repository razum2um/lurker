generate 'rspec:install'
generate 'model User name:string'

route <<-ROUTE
  namespace :api do
    namespace :v1 do
      resources :users
    end
  end
ROUTE

file 'app/controllers/api/v1/users_controller.rb', 'Api::V1::UsersController' do
  <<-CODE
    class Api::V1::UsersController < ActionController::Base
      before_filter :set_format

      def index
        @users = User.all
        render json: @users
      end

      def create
        @user = User.create(params[:user])
        render json: @user
      end

      def show
        @user = User.find(params[:id])
        render json: @user
      end

      def destroy
        @user = User.find(params[:id])
        @user.destroy
        render head: :ok
      end

      private

      def set_format
        request.format = :json
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
        !(src.filename =~ /\\/lib\\/lurker/ && src.filename =~ /^\#{SimpleCov.root}/)
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
  end
CODE

run 'rake db:migrate'
run 'rake db:migrate', env: 'test'
run %q{bin/rails r "User.create(name: 'admin')"}

