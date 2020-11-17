Feature: schema updating within test suite

  If your API is stable and the new code isn't breaking it
  you'll see nothing special, just passing specs

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
              example: 'Bob'
    responseCodes:
    - status: 400
      successful: true
      description: ''
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
          example: 1
        name:
          description: ''
          type: string
          example: razum2um
        surname:
          description: ''
          type: string
          example: Unknown
    extensions:
      method: PATCH
      path_info: "/api/v2/users/1"
      path_params:
        controller: api/v2/users
        action: update
        id: '1'
    """

  Scenario: json schema tests response parameters and request parameters and show errors from both using "users/update"
  Given a file named "spec/controllers/api/v2/users_controller_blank_spec.rb" with:
    """ruby
      describe Api::V2::UsersController, :lurker do
        render_views

        let(:user) do
          User.where(name: 'razum2um', surname: 'Unknown').first_or_create!
        end

        it "updates a user surname as string" do
          patch :update, params: { id: user.id, user: { name: '', surname: 'Marley' } }
          expect(response).not_to be_success
        end
      end
    """

  When I run `bin/rspec spec/controllers/api/v2/users_controller_blank_spec.rb`
  Then the output should contain failures:
    """
    Lurker::ValidationError:
      Request
        The property '#/user' contains additional properties ["surname"]
      Response
        The property '#/' contains additional properties ["errors"]

    1 example, 1 failure
    """

  Scenario: json schema tests response parameters and update request parameters using "users/update"
  Given a file named "spec/controllers/api/v2/users_controller_spec.rb" with:
    """ruby
      describe Api::V2::UsersController, :lurker do
        render_views

        let(:user) do
          User.where(name: 'razum2um', surname: 'Unknown').first_or_create!
        end

        it "updates a user surname as string" do
          patch :update, params: { id: user.id, user: { surname: 'Marley' } }
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
              example: Bob
            surname:
              description: ''
              type: string
              example: Marley
    responseCodes:
    - status: 400
      successful: true
      description: ''
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
          example: 1
        name:
          description: ''
          type: string
          example: razum2um
        surname:
          description: ''
          type: string
          example: Unknown
    extensions:
      method: PATCH
      path_info: "/api/v2/users/1"
      path_params:
        controller: api/v2/users
        action: update
        id: '1'

    """

