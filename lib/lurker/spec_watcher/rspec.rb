require 'lurker/spy'

module Lurker
  module SpecWatcher
    module Rspec
      extend ActiveSupport::Concern
      ACTIONS = [:get, :post, :put, :delete, :patch].freeze

      included do
        ACTIONS.each do |verb|
          send(:define_method, "#{verb}_with_lurker") do |*params|
            action, request_params, env = params

            request_params ||= {}
            env ||= {}

            if action.is_a?(Symbol)
              unless @_example.metadata.described_class.is_a?(Class)
                raise 'cannot determine request url: provide proper described class like: "describe MyController do"'
              end
              controller_name = @_example.metadata.described_class.name.tableize.gsub(/_controllers$/, '')
              action = URI.parse(url_for({ controller: controller_name, action: action }.merge(request_params))).path
            end

            send("#{verb}_without_lurker", action, request_params, env)
          end

          begin
            send :alias_method_chain, verb, :lurker
          rescue NameError
            if verb == :patch
              alias_method :patch_without_lurker, :put_without_lurker
              alias_method :patch, :patch_with_lurker
            else
              raise
            end
          end
        end
      end
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|
    # obsolete, support controller -> request migration
    # supports `get :index` in request specs
    config.include Lurker::SpecWatcher::Rspec, type: :request

    lurker = ->(example) {
      # RSpec::Core::ExampleGroup::Nested_1 === self
      @_example = example

      #binding.pry
      if (metadata = example.metadata[:lurker]).present?
        Lurker::Spy.on(suffix: metadata, &example)
      else
        example.call
      end
    }

    config.around(:each, type: :controller, &lurker)
    config.around(:each, type: :request, &lurker)
  end
end
