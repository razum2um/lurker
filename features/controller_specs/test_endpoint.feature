Feature: test endpoint

  If your API is stable and the new code isn't breaking it
  you'll see nothing special, just passing specs

  NOTE: the second request example is expecting a nonsuccessful response and it is,
  but specs are NOT passing because of nonsufficient `name` parameter

  NOTE: the third response example is expecting a successful response and it is,
  but specs are NOT passing because of nonsufficient `role` attribute

  Scenario: json schema tests request and response
    Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::UsersController, :lurker do
        render_views

        it "creates a new users" do
          post :create, name: 'Bob'
          expect(response).to be_success
        end
      end
      """
    Given a file named "lurker/api/v1/users-POST.json.yml" with:
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
          name:
            description: ''
            type: string
            example: Bob
        required: []
      responseParameters:
        properties:
          id:
            description: ''
            type: 'null'
            example:
          name:
            description: ''
            type: 'null'
            example:
        required: []
      extensions:
        action: create
        controller: api/v1/users
        path_info: "/api/v1/users"
        method: POST
        suffix: ''
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
  Then the example should pass

  Scenario: json schema tests request parameters and tell what fails
    Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::UsersController, :lurker do
        render_views

        it "creates a new users" do
          post :create, name: 1
          expect(response).not_to be_success
        end
      end
      """
    Given a file named "lurker/api/v1/users-POST.json.yml" with:
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
          name:
            description: ''
            type: string
            example: Bob
        required: []
      responseParameters:
        properties:
          id:
            description: ''
            type: 'null'
            example:
          name:
            description: ''
            type: 'null'
            example:
        required: []
      extensions:
        action: create
        controller: api/v1/users
        path_info: "/api/v1/users"
        method: POST
        suffix: ''
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
  Then the output should contain:
    """
    1 example, 1 failure
    """
  Then the output should contain:
    """
    The property '#/name' of type Fixnum did not match the following type: string
    """

  Scenario: json schema tests response parameters and tell what fails
    Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe Api::V1::UsersController, :lurker do
        render_views

        it "creates a new users" do
          post :create, name: 'John'
          expect(response).to be_success
        end
      end
      """
    Given a file named "lurker/api/v1/users-POST.json.yml" with:
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
          name:
            description: ''
            type: string
            example: Bob
        required: []
      responseParameters:
        properties:
          id:
            description: ''
            type: 'null'
            example:
          name:
            description: ''
            type: 'null'
            example:
          role:
            description: ''
            type: 'null'
            example:
        required: ['role']
      extensions:
        action: create
        controller: api/v1/users
        path_info: "/api/v1/users"
        method: POST
        suffix: ''
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
  Then the output should contain:
    """
    1 example, 1 failure
    """
  Then the output should contain:
    """
    The property '#/' did not contain a required property of 'role'
    """
