Feature: html generation

  @javascript
  Scenario: json schema gets generated into html preview
    Given an empty directory named "lurker"
    And an empty directory named "html"
    And a file named "lurker/api/v1/users-POST.json.yml" with:
      """yml
      ---
      prefix: 'Users'
      description: 'User creation'
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
            type: integer
            example: 1
          name:
            description: ''
            type: string
            example: Bob
        required: []
      extensions:
        action: create
        controller: api/v1/users
        path_info: "/api/v1/users"
        method: POST
        suffix: ''
      """

  When I successfully run `bin/lurker convert`
  Then the output should contain:
    """
    Converting lurker to html
    """
  When I run `find html`
  Then the output should contain:
    """
    html/api/v1/users-POST.html
    """
  When I go to "/lurker"
  Then I should see "Users"
  When I click on "Users"
  Then I should see "User creation"

