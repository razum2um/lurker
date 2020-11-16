Feature: controller schema scaffolding

  When you prefer to test controller not in a unit-test fashion,
  but including `render_views` - you can add `:lurker` metadata
  to get a json schema for your api-documented endpoint

  Scenario: scaffold a json schema for a "users/show" in controller spec
    Given a file named "spec/controllers/api/v1/users_controller_spec.rb" with:
      """ruby
      describe Api::V1::UsersController, :lurker do
        render_views

        let!(:user) do
          User.where(name: 'razum2um', surname: 'Marley').first_or_create!
        end

        it "shows user" do
          get :show, params: { id: user.id, format: 'json' }
          expect(response).to be_success
        end
      end
      """

  When I run `bin/rspec spec/controllers/api/v1/users_controller_spec.rb`
  Then the example should pass
  Then a file named "lurker/api/v1/users/__id-GET.json.yml" should exist
  Then the file "lurker/api/v1/users/__id-GET.json.yml" should contain exactly:
    """yml
    ---
    description: user
    prefix: users management
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
          example: Marley
    extensions:
      method: GET
      path_info: "/api/v1/users/1.json"
      path_params:
        controller: api/v1/users
        action: show
        id: '1'

  """

