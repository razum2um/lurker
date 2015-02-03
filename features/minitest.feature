Feature: minitest

  When you're testing your api with `minitest` and
  `ActionDispatch::IntegrationTest`: you can
  simply wrap your code in `Lurker::Spy.on do ... end`

  Scenario: scaffold a json schema for a "repos/destroy" in minitest
    Given a file named "test/integration/destroy_repo_test.rb" with:
      """ruby
      require_relative '../test_helper'

      class DestroyRepoTest < ActionDispatch::IntegrationTest
        def test_destruction
          user = User.where(name: 'razum2um').first_or_create!
          repo = user.repos.first_or_create!(name: 'lurker')

          assert_equal 1, Repo.count

          Lurker::Spy.on do
            delete "/api/v1/users/#{user.id}/repos/#{repo.id}.json"
          end

          assert_equal 200, status
          assert_equal 0, Repo.count
        end
      end
      """

  When I run `ruby test/integration/destroy_repo_test.rb`
  Then the output should contain unescaped these lines:
    """
    1 (runs|tests), 3 assertions, 0 failures, 0 errors, 0 skips
    """
  Then a file named "lurker/api/v1/users/__user_id/repos/__id-DELETE.json.yml" should exist
  Then the file "lurker/api/v1/users/__user_id/repos/__id-DELETE.json.yml" should contain exactly:
    """yml
    ---
    description: repo descruction
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
      properties: {}
    extensions:
      method: DELETE
      path_info: "/api/v1/users/1/repos/1.json"
      path_params:
        controller: api/v1/repos
        action: destroy
        user_id: '1'
        id: '1'

    """

  Scenario: json schema tests "users/update" in minitest
    Given a file named "lurker/api/v1/users/__id-PATCH.json.yml" with:
      """yml
      ---
      prefix: 'users management'
      description: 'user updating'
      requestParameters:
        properties:
          id:
            type: integer
            example: 1
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
      extensions:
        path_info: "/api/v1/users/1"
        method: PATCH
        path_params:
          controller: api/v1/users
          action: update
          id: 1
          """

    And a file named "test/integration/update_user_test.rb" with:
      """ruby
      require_relative '../test_helper'

      class UpdateUserTest < ActionDispatch::IntegrationTest
        def test_updating
          user = User.where(name: 'razum2um').first_or_create!
          assert_equal 1, User.count

          Lurker::Spy.on do
            patch "/api/v1/users/#{user.id}.json", user: { name: '' }
          end

          assert_equal 200, status
          assert_equal 'John', user.reload.name
        end
      end
      """

  When I run `ruby test/integration/update_user_test.rb`
  Then the output should contain failures:
    """
    Lurker::ValidationError:
      Response
        The property '#/' contains additional properties ["errors"]

    """
  And the output should contain unescaped these lines:
    """
    1 (runs|tests), 1 assertions, 0 failures, 1 errors, 0 skips
    """

