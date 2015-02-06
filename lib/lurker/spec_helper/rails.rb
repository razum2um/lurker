require 'active_support/concern'
require 'lurker/spy'

module Lurker
  module SpecHelper
    module Rails
      extend ActiveSupport::Concern

      module ClassMethods
        module LurkerSession
          def process(*)
            super.tap do
              if Lurker::Spy.enabled?
                [:@request, :@response].each do |iv_name|
                  if !instance_variable_defined?(iv_name) || instance_variable_get(iv_name).nil?
                    raise Lurker::Spy::BlindError.new("#{iv_name} is nil: make sure you set it in your test's setup method.")
                  end
                end

                Lurker::Spy.current.request  = Lurker::Request.build_from_action_dispatch(@request)
                Lurker::Spy.current.response = Lurker::Response.build_from_action_dispatch(@response)
              end
            end
          end
        end

        def new(*)
          super.extend(LurkerSession)
        end
      end
    end
  end
end

if defined?(ActionDispatch::Integration::Session)
  ActionDispatch::Integration::Session.send :include, Lurker::SpecHelper::Rails
end

if defined?(ActionController::TestCase::Behavior)
  ActionController::TestCase::Behavior.send :include, Lurker::SpecHelper::Rails
end

