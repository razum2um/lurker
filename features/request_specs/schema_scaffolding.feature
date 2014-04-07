Feature: schema scaffolding

  Scenario: scaffold a json schema for a request spec
    Given a file named "spec/requests/users_spec.rb" with:
      """ruby
      require "spec_helper"

      describe 'User listing', :lurker do
        let!(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        it "lists all the users" do
          get 'api/v1/users'
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/requests/users_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users-GET.json.yml" should exist
  Then the file "lurker/api/v1/users-GET.json.yml" should contain exactly:
    """yml
    ---
    prefix: ''
    description: ''
    responseCodes:
    - status: 200
      successful: true
      description: ''
    requestParameters:
      properties: {}
      required: []
    responseParameters:
      type: array
      items:
        description: ''
        type: object
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
      action: index
      controller: api/v1/users
      path_info: "/api/v1/users"
      method: GET
      suffix: ''

    """

