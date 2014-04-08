Feature: schema scaffolding

  Scenario: scaffold a json schema for a request spec
    Given an empty directory named "lurker"
    Given an empty directory named "spec/requests"
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

  @wip
  Scenario: scaffold multiple request endpoints
    Given an empty directory named "lurker"
    Given an empty directory named "spec/requests"
    Given a file named "spec/requests/user_repos_spec.rb" with:
      """ruby
      require "spec_helper"

      describe 'Repo listing', :lurker do
        let!(:user) do
          User.where(name: 'razum2um').first_or_create!.tap do |u|
            u.repos.create!(name: 'lurker')
          end
        end

        it "lists all the users" do
          get 'api/v1/users'
          expect(response).to be_success
          json = JSON.parse response.body
          expect(json.first['id']).to eq user.id

          get "api/v1/users/#{user.id}/repos"
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/requests/user_repos_spec.rb`
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
  Then a file named "lurker/api/v1/users/__user_id/repos-GET.json.yml" should exist
  Then the file "lurker/api/v1/users/__user_id/repos-GET.json.yml" should contain exactly:
    """yml
    ---
    prefix: ''
    description: ''
    responseCodes:
    - status: 200
      successful: true
      description: ''
    requestParameters:
      properties:
        user_id:
          description: ''
          type: integer
          example: 1
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
          user_id:
            description: ''
            type: integer
            example: 1
          name:
            description: ''
            type: string
            example: lurker
        required: []
    extensions:
      action: index
      controller: api/v1/repos
      user_id: '1'
      path_info: "/api/v1/users/1/repos"
      method: GET
      suffix: ''

    """
