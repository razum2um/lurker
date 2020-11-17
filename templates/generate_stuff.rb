# This is secondary testing/demo rails app template (passed to `rake rails:template`)
def rails_version
  if (version = ENV['BUNDLE_GEMFILE'].to_s.match(/rails_([\d\.]+).gemfile/)&.to_a&.last)
    Gem::Version.new(version)
  end
end

if rails_version
  BASE_DB_NAME = "lurker_app_rails_#{rails_version}"
else
  raise "Export BUNDLE_GEMFILE=gemfiles/rails_... explicitly"
end

file 'config/database.yml', force: true do
  <<~CODE
default: &default
  adapter: postgresql
  encoding: unicode
  database: #{BASE_DB_NAME}
  pool: 5
test:
  <<: *default
  database: #{BASE_DB_NAME}_test
development:
  <<: *default
production:
  url: <%= ENV['DATABASE_URL'] %>
  CODE
end

copy_file "#{File.expand_path '../../bin/lurker', __FILE__}", "bin/lurker"
inject_into_file "bin/lurker", before: /require .lurker.$/ do
  <<~CODE
    if (simplecov_root = ENV['SIMPLECOV_ROOT']) && (simplecov_cmdname = ENV['SIMPLECOV_CMDNAME'])
      require 'simplecov'
      SimpleCov.start
      SimpleCov.root simplecov_root
      SimpleCov.command_name "\#{simplecov_cmdname}-binstub"
      SimpleCov.start do
        filters.clear # This will remove the :root_filter that comes via simplecov's defaults
        add_filter do |src|
          # WTF??? if erb_schema_context gets into .resultset.json second time
          # coveralls WONT calculate overall coverage... o_O
          src.filename =~ /erb_schema_context/ || !(src.filename =~ /^\#{SimpleCov.root}\\/lib\\/lurker/)
        end
      end
    end
  CODE
end
chmod "bin/lurker", 0755

# not to disturb generators
remove_file 'spec/spec_helper.rb'
remove_file 'app/models/user.rb'

generate 'rspec:install'

route <<~ROUTE
  namespace :api do
    namespace :v1 do
      resources :users do
        resources :repos
      end
    end

    namespace :v2 do
      resources :users do
        resources :repos
      end
    end

    namespace :v3 do
      resources :users do
        resources :repos
      end
    end
  end

  get '/robots.txt', to: proc { |env| [
    200,
    { "Content-Type" => 'text/plain' },
    [ "User-agent: *\\nDisallow: /" ]
  ]}

  root to: redirect('/lurker')
ROUTE

remove_file 'public/robots.txt'

generate 'model User name:string surname:string --no-timestamps --no-test-framework --no-migration'
generate 'model Repo user:references name:string --no-timestamps --no-test-framework --no-migration'

file 'config/initializers/serializer.rb', force: true do
  <<~CODE
    module ExactOrderAsJson
      # we need EXACT order for json attributes generation (e.g. rails32 sorts it)
      # see: https://github.com/rails/rails/pull/5678/files
      #
      # options[:only] gets ordered like `attributes.keys` (via &=)
      # attributes order is also inconsistent, so use options[:methods]
      def as_json(options={})
        methods = options[:methods] || []
        if options[:only]
          options[:methods] = Array.wrap(options[:only]).sort + methods
        else
          options[:methods] = attributes.keys.sort + methods
        end
        options[:methods] -= Array.wrap(options[:except])
        options[:only] = options[:except] = []

        super(options)
      end
    end
  CODE
end

inject_into_class 'app/models/user.rb', 'User' do
  <<~CODE
    include ExactOrderAsJson
    has_many :repos
    validates :name, presence: true

    def surname
      read_attribute(:surname).to_s
    end
  CODE
end

inject_into_class 'app/models/repo.rb', 'Repo' do
  <<~CODE
    include ExactOrderAsJson
    validates :name, presence: true
  CODE
end

file 'app/controllers/application_controller.rb', 'ApplicationController', force: true do
  <<~CODE
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session
      before_action :set_format

      private

      def set_format
        request.format = :json
      end

      def scoped(klass)
        if klass.respond_to?(:scoped) # Rails3
          klass.scoped
        else
          klass.all
        end
      end
    end
  CODE
end

file 'app/controllers/api/v1/users_controller.rb', 'Api::V1::UsersController', force: true do
  <<~CODE
    class Api::V1::UsersController < ApplicationController
      def index
        @users = scoped(User)
        if (limit = params[:limit]).to_s.match(/\\d+/)
          @users = @users.limit(limit.to_i)
        end
        render json: @users.order('id ASC')
      end

      def create
        @user = User.new(user_params)
        if @user.save
          render json: @user
        else
          render json: { errors: @user.errors }, status: :bad_request
        end
      end

      def update
        if user.update(user_params)
          render json: user
        else
          render json: { errors: user.errors }, status: :bad_request
        end
      end

      def show
        render json: user
      end

      def destroy
        user.destroy
        render json: true
      end

      private

      def user
        @user ||= (User.find_by_name(params[:id]) || User.find(params[:id]))
      end

      def user_params
        @user_params = params[:user]
        if @user_params.respond_to? :permit
          @user_params.permit(:name, :surname)
        else
          @user_params
        end
      end
    end
  CODE
end

file 'app/controllers/api/v1/repos_controller.rb', 'Api::V1::ReposController', force: true do
  <<~CODE
    class Api::V1::ReposController < ApplicationController

      def index
        @repos = user.repos
        if (limit = params[:limit]).to_s.match(/\\d+/)
          @repos = @repos.limit(limit.to_i)
        end
        render json: @repos.order('id ASC')
      end

      def create
        @repo = user.repos.build(repo_params)
        if @repo.save
          render json: @repo.to_json(include: 'user', except: 'user_id')
        else
          render json: { errors: @repo.errors }, status: :bad_request
        end
      end

      def show
        render json: repo
      end

      def update
        @repo = repo
        if @repo.update(repo_params)
          render json: @repo
        else
          render json: { errors: @repo.errors }, status: :bad_request
        end
      end


      def destroy
        Repo.find(params[:id]).destroy
        render json: true
      end

      private

      def repo
        @repo ||= (user.repos.find_by_name(params[:id]) || user.repos.find(params[:id]))
      end

      def user
        @user ||= (User.find_by_name(params[:user_id]) || User.find(params[:user_id]))
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

[2, 3].each do |version|
  file "app/controllers/api/v#{version}/users_controller.rb", "Api::V#{version}::UsersController", force: true do
    <<~CODE
      class Api::V#{version}::UsersController < Api::V1::UsersController; end
    CODE
  end

  file "app/controllers/api/v#{version}/repos_controller.rb", "Api::V#{version}::ReposController", force: true do
    <<~CODE
      class Api::V#{version}::ReposController < Api::V1::ReposController; end
    CODE
  end
end

# FIXME: uninitialized constant User (NameError) in last creation line
append_to_file 'config/environment.rb' do
  <<~CODE
    $:.unshift File.expand_path('../../app/models', __FILE__)
  CODE
end

inject_into_class 'config/application.rb', 'Application' do
  <<~CODE
    if ENV['DATABASE_URL'].present? # heroku
      config.middleware.use Lurker::Sandbox
    end

    require 'rack/cors' # FIXME
    config.middleware.insert 0, Rack::Cors do
      allow do
        origins %w[localhost:3000 127.0.0.1:3000 razum2um.github.io lurker-app.herokuapp.com lurker.razum2um.me]
        resource '*',
          :headers => :any,
          :methods => [:get, :post, :delete, :put, :options, :head],
          :credentials => false,
          :expose => %w[Etag Server X-Content-Type-Options X-Frame-Options X-Request-Id X-Runtime
                        X-Xss-Protection Date Access-Control-Request-Method Access-Control-Allow-Origin
                        Connection Content-Length].join(',')
      end
    end
  CODE
end

file 'test/test_helper.rb', force: true do
  <<~CODE
    ENV['RAILS_ENV'] ||= 'test'
    require File.expand_path('../../config/environment', __FILE__)
    require 'rails/test_help'
    require 'database_cleaner'

    class ActionDispatch::IntegrationTest
      def setup
        super if defined? super
        [User, Repo].each do |klass|
          ActiveRecord::Base.connection.execute "ALTER SEQUENCE \#{klass.sequence_name} RESTART WITH 1"
        end
        DatabaseCleaner.start
      end

      def teardown
        super if defined? super
        DatabaseCleaner.clean
      end
    end
  CODE
end

file 'spec/support/fixme.rb', force: true do
  <<~CODE
    require 'simplecov'

    module ActionDispatchTestResponseCompat
      def success?
        status == 200
      end
    end
    ActionDispatch::TestResponse.include(ActionDispatchTestResponseCompat)

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

    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation

    RSpec.configure do |c|
      c.infer_spec_type_from_file_location! if c.respond_to?(:infer_spec_type_from_file_location!)
      c.backtrace_exclusion_patterns += [
        /\\/lib\\/lurker/
      ]

      c.before do
        [User, Repo].each do |klass|
          ActiveRecord::Base.connection.execute "ALTER SEQUENCE \#{klass.sequence_name} RESTART WITH 1"
        end
        DatabaseCleaner.start
      end

      c.after do
        DatabaseCleaner.clean
      end
    end

    require 'lurker/spec_helper'

  CODE
end

file 'lib/tasks/db.rake', force: true do
  <<~CODE
    namespace :db do
      desc 'fills in data'
      task :import => :environment do
        User.where(name: "razum2um").first_or_create.repos.where(name: "lurker").first_or_create
        User.where(name: "razum2um").first_or_create.repos.where(name: "resque-kalashnikov").first_or_create
        User.where(name: "razum2um").first_or_create.repos.where(name: "mutli_schema").first_or_create
      end
    end
  CODE
end

file 'db/schema.rb', force: true do
  <<~CODE
    ActiveRecord::Schema.define do
      create_table "repos", :force => true do |t|
        t.integer "user_id"
        t.string  "name"
      end

      add_index "repos", ["user_id"], :name => "index_repos_on_user_id"

      create_table "users", :force => true do |t|
        t.string "name"
        t.string "surname"
      end
    end
  CODE
end

append_to_file 'spec/rails_helper.rb' do
  <<~CODE
    Dir[File.expand_path '../support/**/*.rb', __FILE__].each { |file| require file }
    CODE
end

if rails_version < Gem::Version.new('5')
  append_to_file 'spec/rails_helper.rb' do
    <<~CODE  
      require 'rails/forward_compatible_controller_tests'
      RSpec.configure do |config|
        config.include Rails::ForwardCompatibleControllerTests, type: :controller
        config.include Rails::ForwardCompatibleControllerTests, type: :request
      end
    CODE
  end
end

append_to_file '.rspec' do
  <<~CODE
    --require rails_helper
  CODE
end

copy_file "#{File.expand_path '../../templates/Dockerfile', __FILE__}", "Dockerfile"

# rails-4 requires this
file 'app/assets/config/manifest.js', force: true do
  <<~CODE
  // empty
  CODE
end

copy_file "#{File.expand_path '../../templates/rails4_ruby26_thread_error_fix.rb', __FILE__}", "spec/support/rails4_ruby26_thread_error_fix.rb"
