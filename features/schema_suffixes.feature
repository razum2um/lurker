Feature: schema suffixes

  If your API is stable and the new code isn't breaking it
  you'll see nothing special, just passing specs

  **NOTE:** the second request example is expecting a nonsuccessful response and it is,
  but specs are NOT passing because of nonsufficient `name` parameter

  **NOTE:** the third response example is expecting a successful response and it is,
  but specs are NOT passing because of nonsufficient `role` attribute

  Scenario: json schema tests request and response using "repos/update"
    Given a file named "lurker/api/v1/users/__user_id/repos/__id-PATCH.json.yml" with:
      """yml
      ---
      prefix: 'repos management'
      description: 'repo updating'
      requestParameters:
        properties:
          id:
            type: string
            example: 1
          user_id:
            type: string
            example: razum2um
          repo:
            type: object
            properties:
              name:
                type: string
                example: 'updated-name'
      responseCodes:
      - status: 200
        successful: true
        description: ''
      responseParameters:
        properties:
          id:
            type: integer
            example: 1
          name:
            type: string
            example: 'updated-name'
          user_id:
            type: integer
            example: 1
        required: []
      extensions:
        path_info: "/api/v1/users/razum2um/repos/lurker.json"
        method: PATCH
        path_params:
          controller: api/v1/repos
          action: update
          user_id: razum2um
          id: lurker
      """
    And a file named "spec/requests/updating_repos_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::ReposController, :lurker, type: :request do

        let(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        let(:repo) do
          user.repos.where(name: 'lurker').first_or_create!
        end

        it "updates a repo name" do
          expect {
            patch "/api/v1/users/#{user.name}/repos/#{repo.name}.json", repo: { name: 'updated-name' }
            expect(response).to be_success
          }.to change { repo.reload.name } .from('lurker').to('updated-name')
        end
      end
      """

  When I run `bin/rspec spec/requests/updating_repos_spec.rb`
  Then the example should pass

  Scenario: json schema tests request parameters and tell what fails using "users/update"
    Given a file named "lurker/api/v1/users/__user_id/repos/__id-failed-PATCH.json.yml" with:
      """yml
      ---
      prefix: 'repos management'
      description: 'failed repo updating'
      requestParameters:
        properties:
          id:
            type: string
            example: 1
          user_id:
            type: string
            example: razum2um
          repo:
            type: object
            properties:
              name:
                type: string
                example: ''
      responseCodes:
      - status: 400
        successful: true
        description: ''
      responseParameters:
        properties:
          errors:
            type: object
            example: 1
            properties:
              name:
                type: array
                items:
                  type: string
                  example: can't be blank
      extensions:
        path_info: "/api/v1/users/razum2um/repos.json"
        method: PATCH
        suffix: 'failed'
        path_params:
          controller: api/v1/repos
          action: update
          user_id: razum2um
          id: lurker
      """
    And a file named "spec/requests/failed_updating_repos_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::ReposController, type: :request do

        let(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        let(:repo) do
          user.repos.where(name: 'lurker').first_or_create!
        end

        it "fails to update a repo with a blank name", lurker: 'failed' do
          expect {
            patch "/api/v1/users/#{user.name}/repos/#{repo.name}.json", repo: { name: '' }
            expect(response).not_to be_success
          }.not_to change { repo.reload.name }
        end
      end
      """

  When I run `bin/rspec spec/requests/failed_updating_repos_spec.rb`
  Then the example should pass

