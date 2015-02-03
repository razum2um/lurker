Feature: controller nested schema scaffolding

  If your API endpoint has some dynamic segment - Lurker can handle it as well!

  Scenario: scaffold a json schema for a "repos/index" in a nested controller spec
    Given a file named "spec/controllers/api/v1/repos_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::ReposController, :lurker do
        render_views

        let!(:user) do
          User.where(name: 'razum2um').first_or_create!.tap do |u|
            u.repos.first_or_create!(name: 'lurker')
            u.repos.first_or_create!(name: 'multi_schema')
          end
        end

        it "lists all the repos of the user" do
          get :index, user_id: user.id, limit: 1, format: 'json'
          expect(response).to be_success
          expect(JSON.parse(response.body).size).to eq 1
        end
      end
      """

  When I run `bin/rspec spec/controllers/api/v1/repos_controller_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users/__user_id/repos-GET.json.yml" should exist
  Then the file "lurker/api/v1/users/__user_id/repos-GET.json.yml" should contain exactly:
    """yml
    ---
    description: repo listing
    prefix: repos management
    requestParameters:
      description: ''
      type: object
      additionalProperties: false
      required: []
      properties:
        limit:
          description: ''
          type: integer
          example: 1
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
            example: lurker
          user_id:
            description: ''
            type: integer
            example: 1
    extensions:
      method: GET
      path_info: "/api/v1/users/1/repos.json"
      path_params:
        controller: api/v1/repos
        action: index
        user_id: '1'
      query_params:
        limit: 1

    """

