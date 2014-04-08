Feature: schema scaffolding

  Scenario: scaffold a json schema for a "users/show" in request spec
    Given a file named "spec/requests/users_spec.rb" with:
      """ruby
      require "spec_helper"

      describe 'User attributes', :lurker do
        let!(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        it "lists all the users" do
          get "api/v1/users/#{user.id}"
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/requests/users_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users/__id-GET.json.yml" should exist
  Then the file "lurker/api/v1/users/__id-GET.json.yml" should contain exactly:
    """yml
    ---
    prefix: users management
    description: user
    responseCodes:
    - status: 200
      successful: true
      description: ''
    requestParameters:
      properties: {}
      required: []
    responseParameters:
      properties:
        id:
          description: ''
          type: integer
          example: 1
        name:
          description: ''
          type: string
          example: razum2um
      required: []
    extensions:
      action: show
      controller: api/v1/users
      id: '1'
      path_info: "/api/v1/users/1"
      method: GET
      suffix: ''

  """
