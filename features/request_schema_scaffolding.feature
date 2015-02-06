Feature: request schema scaffolding

  When you're testing your api with request specs
  you can add `:lurker` metadata
  to get a json schema for your api-documented endpoint

  Scenario: scaffold a json schema for a "users/index" in request spec
    Given a file named "spec/requests/users_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::UsersController, :lurker do
        let!(:user) do
          User.where(name: 'razum2um', surname: 'Marley').first_or_create!
        end

        let!(:bot) do
          User.where(name: 'bot', surname: 'google').first_or_create!
        end

        it "lists all the users" do
          get "/api/v1/users.json?limit=1"
          expect(response).to be_success
          expect(JSON.parse(response.body).size).to eq 1
        end
      end
      """

  When I run `bin/rspec spec/requests/users_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users-GET.json.yml" should exist
  Then the file "lurker/api/v1/users-GET.json.yml" should contain exactly:
    """yml
    ---
    description: user listing
    prefix: users management
    requestParameters:
      description: ''
      type: object
      additionalProperties: false
      required: []
      properties:
        limit:
          description: ''
          type: string
          example: '1'
    responseCodes:
    - status: 200
      successful: true
      description: ''
    responseParameters:
      type: array
      items:
        description: ''
        type: object
        additionalProperties: false
        required: []
        properties:
          id:
            description: ''
            type: integer
            example: 1
          name:
            description: ''
            type: string
            example: razum2um
          surname:
            description: ''
            type: string
            example: Marley
    extensions:
      method: GET
      path_info: "/api/v1/users.json"
      path_params:
        controller: api/v1/users
        action: index
      query_params:
        limit: '1'

    """

