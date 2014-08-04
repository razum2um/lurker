Feature: $ref defererencing through inlining
  Background:
    Given a checked file "lurker/api/v3/users/__id-PATCH.json.yml" with:
      """yml
      ---
      description: user updating
      prefix: users management
      requestParameters:
        description: ''
        type: object
        additionalProperties: false
        required: []
        properties:
          user:
            "$ref": "../../../definitions/user_request_parameters.json#/"
      responseCodes:
      - status: 200
        successful: true
        description: ''
      responseParameters:
        "$ref": "../../../definitions/user.json#/"
      extensions:
        method: PATCH
        path_info: "/api/v3/users/1"
        path_params:
          id: '1'
          controller: api/v3/users
          action: update

      """
    And a file named "lurker/definitions/user_request_parameters.json" with:
      """json
      {
        "properties": {
          "name": {
            "type": "string",
            "example": "Bob"
          }
        }
      }
      """
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
    And a file named "spec/controllers/api/v3/users_controller_spec.rb" with:
      """ruby
        require "spec_helper"

        describe Api::V3::UsersController, :lurker do
          render_views

          let(:user) do
            User.where(name: 'razum2um', surname: 'Unknown').first_or_create!
          end

          it "updates a user surname as string" do
            patch :update, id: user.id, user: { surname: 'Marley' }
            expect(response).to be_success
          end
        end
      """

  Scenario: json schema left $ref keyword as is using "users/update"
    When I run `bin/rspec spec/controllers/api/v3/users_controller_spec.rb`
    Then the example should pass
    Then a file named "lurker/api/v3/users/__id-PATCH.json.yml" should exist
    Then the checked file "lurker/api/v3/users/__id-PATCH.json.yml" should not change
    Then a file named "lurker/definitions/user_request_parameters.json" should exist
    Then the file "lurker/definitions/user_request_parameters.json" should contain exactly:
      """json
      {
        "description": "",
        "type": "object",
        "additionalProperties": false,
        "required": [

        ],
        "properties": {
          "name": {
            "description": "",
            "type": "string",
            "example": "Bob"
          },
          "surname": {
            "description": "",
            "type": "string",
            "example": "Marley"
          }
        }
      }
      """
