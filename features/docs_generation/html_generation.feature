Feature: html generation

  When testing your api ensure that CSRF protection is handled properly
  with `protect_from_forgery :null_session`

  @javascript
  Scenario: json schema gets generated into html preview using "users/create"
    Given an empty directory named "html"
    And a file named "lurker/api/v1/users-POST.json.yml" with:
      """yml
      ---
      prefix: users management
      description: user creation
      requestParameters:
        properties:
          user:
            description: ''
            type: object
            properties:
              name:
                description: ''
                type: string
                example: Bob
            required: []
        required: []
      responseCodes:
      - status: 200
        successful: true
        description: ''
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
        method: POST
        path_info: "/api/v1/users"
        path_params:
          action: create
          controller: api/v1/users
        suffix: ''
      """

  When I successfully run `bin/lurker convert`
  Then the output should contain these lines:
    """
            Converting lurker to html
     using  lurker

    create  index.html
    create  api/v1/users-POST.html
    """

  When I go to "/lurker"
  Then I should see "users management"

  When I click on "users management"
  Then I should see "user creation"

  When I click on "user creation"
  And I fill in the submit form field "name" with "Jim"
  Then I should see:
    """
    curl -X POST -d "user%5Bname%5D=Jim"
    """

   And I submit lurk form

  Then I should see JSON response with "Jim"

  When I fill in the submit form field "name" with ""
   And I submit it

  Then I should see JSON response with "can't be blank"
