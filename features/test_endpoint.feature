Feature: test endpoint

  If your API is stable and the new code isn't breaking it
  you'll see nothing special, just passing specs

  **NOTE:** the second request example is expecting a successful response and it is,
  but specs are NOT passing because of nonsufficient `name` parameter

  **NOTE:** the third response example is expecting a successful response and it is,
  but specs are NOT passing because of nonsufficient `role` attribute

  Background:
    Given a file named "lurker/api/v1/users/__id-PATCH.json.yml" with:
      """yml
      ---
      prefix: 'users management'
      description: 'user updating'
      requestParameters:
        properties:
          user:
            type: object
            properties:
              name:
                type: string
                example: Bob
      responseCodes:
      - status: 400
        successful: true
        description: ''
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
            example: Bob
          surname:
            type: string
            example: Marley
      extensions:
        path_info: "/api/v1/users/1"
        method: PATCH
        path_params:
          controller: api/v1/users
          action: update
          id: 1
      """

  Scenario: json schema tests request and response using "users/update"
    Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
      """ruby
      describe Api::V1::UsersController, :lurker do
        render_views

        let(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        it "updates a user" do
          patch :update, params: { id: user.id, user: { name: 'Bob' } }
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
  Then the example should pass

  Scenario: json schema tests response parameters and tell what fails using "users/update"
    Given a file named "spec/controllers/api/v1/users_controller_blank_spec.rb" with:
      """ruby
      describe Api::V1::UsersController, :lurker do
        render_views

        let(:user) do
          User.where(name: 'razum2um').first_or_create!
        end

        it "updates a user" do
          patch :update, params: { id: user.id, user: { name: '' }, format: 'json' }
          expect(response).not_to be_success
        end
      end
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_blank_spec.rb`
  Then the output should contain failures:
    """
    Lurker::ValidationError:
      Response
        The property '#/' contains additional properties ["errors"]

    1 example, 1 failure
    """

