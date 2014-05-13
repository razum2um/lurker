require 'hashie/dash'

module Lurker
  class Request < Hashie::Dash
    property :verb
    property :endpoint_path
    property :payload, default: {}
  end
end
