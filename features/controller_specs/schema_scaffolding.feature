Feature: schema scaffolding

  When you prefer to test controller not in a unit-test fashion,
  but including `render_views` - you can add `:fdoc` metadata
  to get a json schema for your api-documented endpoint

  Scenario: scaffold a json schema for a controller spec
     Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
       """ruby
       require "spec_helper"

       describe Api::V1::UsersController, :fdoc do

        it "lists all the users" do
          get :index
          expect(response).to be_success
        end

       end
       """

   When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
   Then the example should pass
   Then a directory named "lurker" should exist
   # Then a file named "lurker/api/v1/users-GET.fdoc" should exist

