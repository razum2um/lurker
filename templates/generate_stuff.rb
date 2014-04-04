generate 'rspec:install'
generate 'model User name:string'
generate 'inherited_resources_controller Api::V1::User --no-view-specs --no-helper --no-template-engine --no-request-specs --no-routing-specs --no-controller-specs'

inject_into_class 'app/controllers/api/v1/users_controller.rb', 'Api::V1::UsersController' do
  <<-CODE
    respond_to :json
    defaults resource_class: User, collection_name: 'api_v1_users', instance_name: 'api_v1_user'
  CODE
end

append_to_file 'config/environment.rb' do
  <<-CODE
    $:.unshift File.expand_path('../../app/models', __FILE__)
  CODE
end

route <<-ROUTE
  namespace :api do
    namespace :v1 do
      resources :users
    end
  end
ROUTE

run 'rake db:migrate'
run 'rake db:migrate', env: 'test'
run %q{bin/rails r "User.create(name: 'admin')"}

