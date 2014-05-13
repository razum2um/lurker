require 'hashie/dash'

module Lurker
  class Response < Hashie::Dash
    property :status
    property :body, default: {}
    property :extensions, default: {}
  end
end
