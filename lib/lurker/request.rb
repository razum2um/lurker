require 'hashie/dash'

module Lurker
  class Request < Hashie::Dash
    PREFIX = 'action_dispatch.request'

    property :verb, required: true
    property :endpoint_path, required: true
    property :payload, default: {}

    # ext
    property :path_info, required: true
    property :path_params, default: {}
    property :query_params, default: {}

    def self.build_from_action_dispatch(request)
      new(
        verb: request.method,
        endpoint_path: route_name(request),
        path_info: request.path_info,
        path_params: request.env["#{PREFIX}.path_parameters"],
        query_params: request.env["#{PREFIX}.query_parameters"],
        payload: request.env["#{PREFIX}.request_parameters"].merge(
          request.env["#{PREFIX}.query_parameters"]
        )
      )
    end

    def self.route_name(request)
      if defined? Rails
        Rails.application.routes.router.recognize(request) do |route, _|
          return route.path.spec.to_s.sub('(.:format)', '')
        end
      end
    end
  end
end
