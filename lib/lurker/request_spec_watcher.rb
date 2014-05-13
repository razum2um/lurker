require 'lurker'

module Lurker
  module RequestSpecWatcher
    extend ActiveSupport::Concern

    module ClassMethods
      module LurkerSession
        def process(method, path, parameters = nil, headers_or_env = nil)
          super.tap do
            Lurker::Spy.current.request  = Lurker::Request.build_from_action_dispatch(@request)
            Lurker::Spy.current.response = Lurker::Response.build_from_action_dispatch(@response)
          end
        end
      end

      def new(*args, &blk)
        super(*args, &blk).extend(LurkerSession)
      end
    end
  end

  module RspecRequestAction
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

if defined?(RSpec)
  RSpec.configure do |config|
    config.include Lurker::RspecRequestAction, type: :request
    config.around(:each, type: :request) do |example|
      @_example = example
      if (metadata = example.metadata[:lurker]).present?
        Lurker::Spy.on(suffix: metadata, &example)
      else
        example.call
      end
    end
  end
  ActionDispatch::Integration::Session.send :include, Lurker::RequestSpecWatcher
end
