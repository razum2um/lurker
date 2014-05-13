Feature: request nested schema scaffolding

  If your API endpoint has some dynamic segment - Lurker can handle it as well!

  Scenario: scaffold a json schema for a "repos/show" in a nested controller spec
    Given a file named "spec/requests/repos_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::ReposController, :lurker do

        let!(:user) do
          User.where(name: 'razum2um').first_or_create!.tap do |u|
            u.repos.create!(name: 'lurker')
          end
        end

        it "shows a user's repo" do
          get "api/v1/users/#{user.id}/repos/#{user.repos.first.id}"
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/requests/repos_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users/__user_id/repos/__id-GET.json.yml" should exist
  Then the file "lurker/api/v1/users/__user_id/repos/__id-GET.json.yml" should contain exactly:
    """yml
    ---
    description: repo
    prefix: repos management
    requestParameters:
      description: ''
      type: object
      additionalProperties: false
      required: []
      properties: {}
    responseCodes:
    - status: 200
      successful: true
      description: ''
    responseParameters:
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
      path_info: "/api/v1/users/1/repos/1"
      path_params:
        action: show
        controller: api/v1/repos
        user_id: '1'
        id: '1'
      suffix: ''

    """
