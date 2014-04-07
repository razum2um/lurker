Feature: schema scaffolding

  Scenario: scaffold a json schema for a request spec
    Given a file named "spec/requests/users_spec.rb" with:
      """ruby
      require "spec_helper"

      describe 'User listing', :lurker do
        it "lists all the users" do
          get 'api/v1/users'
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/requests/users_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users-GET.json.yml" should exist

  When I run `grep -v 'example' lurker/api/v1/users-GET.json.yml`
  Then the output from "grep -v 'example' lurker/api/v1/users-GET.json.yml" should contain exactly:
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
          name:
            description: ''
            type: string
          created_at:
            description: ''
            type: string
            format: date-time
          updated_at:
            description: ''
            type: string
            format: date-time
        required: []
    extensions:
      action: index
      controller: api/v1/users
      path_info: "/api/v1/users"
      method: GET
      suffix: ''

    """

