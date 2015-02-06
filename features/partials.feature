Feature: partials

  You can use `$ref` to reference to other schemas just like in JSON-Schema documentation
  Paths must be either `http://` or relative filenames

  Referenced files can be either `.json` files, or `.json.yml` (Same JSON in YAML)

  **NOTE:** to reference `file.json.yml` use `$ref: 'file.json#/'`
  All YAML preprocessing happens behind the scene.

  Scenario: builds html for "repos/create" in request spec with nested partials
    Given an empty directory named "public/lurker"
    And a file named "lurker/definitions/user.json.yml" with:
      """yml
      ---
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: razum2um
        surname:
          type: string
          example: Unknown
      """
    And a file named "lurker/definitions/repo.json.yml" with:
      """yml
      ---
      properties:
        id:
          type: integer
          example: 1
        name:
          type: string
          example: new-gem
        user:
          $ref: '../definitions/user.json#/'
      """
    And a file named "lurker/api/v1/users/__user_id/repos-POST.json.yml" with:
      """yml
      ---
      description: repo creation
      prefix: repos management
      requestParameters:
        properties:
          user_id:
            type: string
            example: 1
          repo:
            properties:
              name:
                type: string
                example: new-gem
      responseCodes:
      - status: 200
        successful: true
      responseParameters:
        $ref: '../../../../definitions/repo.json#/'
      extensions:
        method: POST
        path_info: "/api/v1/users/1/repos.json"
        path_params:
          controller: api/v1/repos
          action: create
          user_id: '1'
      """

    Given a file named "spec/requests/repo_creation_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::ReposController, :lurker do
        let!(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        it "creates a new repo" do
          expect {
            post "/api/v1/users/#{user.id}/repos.json", repo: { name: 'new-gem' }
            expect(response).to be_success
            expect(JSON.parse(response.body)['user']).to eq JSON.parse(user.to_json)
          }.to change { Repo.count } .by(1)
        end
      end
      """

  When I run `bin/rspec spec/requests/repo_creation_spec.rb`
  Then the example should pass

  When I successfully run `bin/lurker convert`
  Then the output should contain these lines:
    """
            Converting lurker to html
     using  lurker

    create  public/lurker/index.html
    create  public/lurker/api/v1/users/__user_id/repos-POST.html
    """

