Feature: atom persistent within test suite
  Background:
    Given a file named "lurker/api/v2/users/__id-PATCH.json.yml" with:
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
          description: ''
          type: object
          additionalProperties: false
          required: []
          properties:
            name:
              description: ''
              type: string
              example: NameIsPersistentInExaple
            surname:
              description: ''
              type: string
              example: SurnameIsPersistentInExaple
    responseCodes:
    - status: 200
      successful: true
      description: ''
    responseParameters:
      description: ''
      type: object
      additionalProperties: false
      required: []
      properties:
        id:
          description: ''
          type: integer
          example: 100
        name:
          description: ''
          type: string
          example: NameIsPersistentInExaple
        surname:
          description: ''
          type: string
          example: SurnameIsPersistentInExaple
    extensions:
      method: PATCH
      path_info: "/api/v2/users/100"
      path_params:
        controller: api/v2/users
        action: update
        id: '100'
    """

  Scenario: json schema tests response parameters and keep atom unchanged using "users/update"
  Given a file named "spec/controllers/api/v2/users_controller_spec.rb" with:
    """ruby
      require "spec_helper"

      describe Api::V2::UsersController, :lurker do
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

  When I run `bin/rspec spec/controllers/api/v2/users_controller_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v2/users/__id-PATCH.json.yml" should exist
  Then the file "lurker/api/v2/users/__id-PATCH.json.yml" should contain exactly:
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
          description: ''
          type: object
          additionalProperties: false
          required: []
          properties:
            name:
              description: ''
              type: string
              example: NameIsPersistentInExaple
            surname:
              description: ''
              type: string
              example: SurnameIsPersistentInExaple
    responseCodes:
    - status: 200
      successful: true
      description: ''
    responseParameters:
      description: ''
      type: object
      additionalProperties: false
      required: []
      properties:
        id:
          description: ''
          type: integer
          example: 100
        name:
          description: ''
          type: string
          example: NameIsPersistentInExaple
        surname:
          description: ''
          type: string
          example: SurnameIsPersistentInExaple
    extensions:
      method: PATCH
      path_info: "/api/v2/users/100"
      path_params:
        controller: api/v2/users
        action: update
        id: '100'

    """

