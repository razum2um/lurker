Feature: html generation

  Lurker generates pretty info pages based on schema information
  and form which allow you to test live api.
  When testing your api ensure that CSRF protection is handled properly
  with `protect_from_forgery :null_session`

  @javascript
  Scenario: json schema gets generated into html preview using "users/create"
    Given an empty directory named "public/lurker"
    And a service file with:
      """yml
      ---
      name: Lurker Demo Application
      basePath: ''
      description: ''
      domains:
        'razum2um.me': 'https://lurker.razum2um.me'
      consumes:
      - application/x-www-form-urlencoded
      - application/json
      """
    And a file named "lurker/api/v1/users-POST.json.yml" with:
      """yml
      ---
      prefix: users management
      description: user creation
      requestParameters:
        properties:
          user:
            type: object
            properties:
              name:
                type: string
                example: Bob
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
            example: Bob
        required: []
      extensions:
        method: POST
        path_info: "/api/v1/users.json"
        path_params:
          controller: api/v1/users
          action: create
      """

  When I successfully run `bin/lurker convert`
  Then the output should contain these lines:
    """
            Converting lurker to html
     using  lurker

    public/lurker/index.html
    public/lurker/api/v1/users-POST.html
    """

  When I go to "/lurker"
  Then I should see "users management"

  When I click on "users management"
  Then I should see "user creation"

  When I click on "user creation"
  And I fill in the submit form field "name" with "Jim"
  Then I should see:
    """
    curl -X POST -d 'user%5Bname%5D=Jim'
    """

   And I submit lurk form

  Then I should see JSON response with "Jim"

  When I fill in the submit form field "name" with ""
   And I submit it

  Then I should see JSON response with "can't be blank"

  When I select "application/json" request media type
   And I fill in the submit form field "name" with "Jim"
  Then I should see:
    """
    curl -X POST -H 'Content-Type: application/json' -d '{"user":{"name":"Jim"}}'
    """

   And I submit lurk form

  Then I should see JSON response with "Jim"
