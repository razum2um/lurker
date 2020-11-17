Feature: mutidomain support

  In your `.service.yml` list you domains in form `hostname: url`

  To deploy statically on other domain and be able to send API requests
  you should turn off Access-Control-Allow-Origin restriction
  in config/application.rb (Rails 4)

  ```ruby
  config.action_dispatch.default_headers = {
    'Access-Control-Allow-Origin' => '<YOUR STATIC SERVER>',
    'Access-Control-Request-Method' => 'GET, PUT, POST, DELETE, OPTIONS'
  }
  ```

  @javascript
  Scenario: json schema gets generated into html preview using "users/destroy"
    Given an empty directory named "public/lurker"
    And a service file with:
      """yml
      ---
      basePath: ''
      description: ''
      domains:
        'razum2um.me': 'https://lurker.razum2um.me'
      name: Lurker Demo Application
      extensions: {}
      """
    And a file named "lurker/api/v1/users/__id-DELETE.json.yml" with:
      """yml
      ---
      prefix: users management
      description: user deletion
      requestParameters:
        properties: {}
      responseCodes:
      - status: 200
        successful: true
        description: ''
      responseParameters:
        properties: {}
      extensions:
        method: DELETE
        path_info: "/api/v1/users/1.json"
        path_params:
          controller: api/v1/users
          action: destroy
          id: 1
      """

  When I successfully run `bin/lurker convert`
  Then the output should contain these lines:
    """
            Converting lurker to html
     using  lurker

    public/lurker/index.html
    public/lurker/api/v1/users/__id-DELETE.html
    """

  When I go to "/lurker/api/v1/users/__id-DELETE.html"
  When I select "razum2um.me" hostname
  Then I should see:
    """
    curl -X DELETE 'https://lurker.razum2um.me/api/v1/users/1'
    """

