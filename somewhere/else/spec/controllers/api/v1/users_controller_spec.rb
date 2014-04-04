require "spec_helper"

describe Api::V1::UsersController, :fdoc do

 it "lists all the users" do
   get :index
   expect(response).to be_success
 end

end