module Lurker
  module SpecWatcher
    extend ActiveSupport::Concern

    private

    def wrapper(example)
      # _it = self # RSpec::ExampleGroups::... # instance
      @__example = example
      @__lurker_service = if defined?(Rails)
        Lurker::Service.new(Rails.root.join(Lurker::DEFAULT_SERVICE_PATH).to_s, Rails.application.class.parent_name)
      else
        Lurker::Service.default_service
      end

      example.run.tap do |result|
        unless result.is_a? Exception
          @__lurker_service.persist! #rescue nil
        end
      end
    end

    def verify(verb, endpoint_path)
      if successful = Lurker.decide_success(response_params, real_response.status)
        @__request_params.stringify_keys! # FIXME
        @__lurker_service.verify!(
          verb, endpoint_path, extensions.merge(path_params: path_params),
          parsed_request_params(@__request_params), response_params,
          real_response.status, successful
        )
      end
    end

    def extensions
      @extensions = {
        path_info: request.env['PATH_INFO'],
        method: request.env['REQUEST_METHOD'],
        suffix: ''
      }
      if (suffix = explicit_path(@__example)).is_a?(String)
        @extensions[:suffix] = suffix.gsub(/[^[[:alnum:]]]/, '_')
      end
      if @__query_params.present?
        @extensions[:query_params] = @__query_params
      end
      @extensions
    end

    def path_regexp
      @__path_regexp ||= current_route_params.first.try(:path).try(:spec).to_s.sub('(.:format)', '')
    end

    def path_params
      @__path_params ||= current_route_params.last || {}
    end

    # ActionDispatch::Journey::Route || nil
    def current_route_params
      return [@__current_route, @__path_params] if @__current_route && @__path_params
      router.recognize(request) do |route, _, parameters|
        return [@__current_route = route, @__path_params = parameters]
      end
      [] # never?
    end

    # ActionDispatch::Journey::Router
    def router
      Rails.application.routes.router
    end

    def parsed_request_params request_params
      if request_params.kind_of?(Hash)
        request_params
      else
        begin
          JSON.parse(request_params)
        rescue
          {}
        end
      end
    end

    def explicit_path(_example=nil)
      if _example && _example.respond_to?(:metadata)
        _example.metadata[:lurker]
      elsif defined?(::RSpec) && ::RSpec.respond_to?(:current_example) # Rspec 3
        ::RSpec.current_example.metadata[:lurker]
      elsif respond_to?(:example) # Rspec 2
        example.metadata[:lurker]
      else # Rspec 1.3.2
        opts = {}
        __send__(:example_group_hierarchy).each do |example|
          opts.merge!(example.options)
        end
        opts.merge!(options)
        opts[:lurker]
      end
    end

    def inside_rails_controller_spec?
      defined?(ActionController::Base) && respond_to?(:controller) && controller.is_a?(ActionController::Base)
    end

    def real_response
      if respond_to? :response
        # we are on rails
        response
      else
        # we are on sinatra
        last_response
      end
    end

    def response_params
      begin
        JSON.parse(real_response.body)
      rescue
        {}
      end
    end
  end
end
require 'lurker/controller_spec_watcher'
require 'lurker/request_spec_watcher'
