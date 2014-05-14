Feature: minitest

  When you're testing your api with `minitest` and
  `ActionDispatch::IntegrationTest`: you can
  simply wrap your code in `Lurker::Spy.on do ... end`

  Scenario: scaffold a json schema for a "repos/destroy" in minitest
    Given a file named "test/integration/destroy_repo_test.rb" with:
      """ruby
      require_relative 'test_helper'

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
  Then the output should contain:
    """
    1 runs, 3 assertions, 0 failures, 0 errors, 0 skips
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
        action: destroy
        controller: api/v1/repos
        user_id: '1'
        id: '1'
      suffix: ''

    """


