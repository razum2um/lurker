require 'json'
require 'hashie/dash'

module Lurker
  class Response < Hashie::Dash
    property :status, required: true
    property :body, default: {}

    def self.build_from_action_dispatch(response)
      new(
        status: response.status,
        body: JSON.parse(response.body)
      )
    end
  end
end
