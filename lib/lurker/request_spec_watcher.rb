require 'json'
require 'lurker'

module Lurker
  module RequestSpecWatcher
    extend ActiveSupport::Concern
    include SpecWatcher

    included do
      # _describe = self # RSpec::ExampleGroups::... # class
      actions = [:get, :post, :put, :delete]
      if defined?(ActionDispatch::Request::HTTP_METHODS) && ActionDispatch::Request::HTTP_METHODS.include?('PATCH')
        actions << :patch
      end

      actions.each do |verb|
        send(:define_method, "#{verb}_with_lurker") do |*params|
          @__action, @__request_params, @__env = params

          @__request_params ||= {}
          @__query_params ||= {}
          @__env ||= {}

          if @__action.is_a?(Symbol)
            unless @__example.metadata.described_class.is_a?(Class)
              raise 'cannot determine request url: provide proper described class like: "describe MyController do"'
            end
            controller_name = @__example.metadata.described_class.name.tableize.gsub(/_controllers$/, '')
            @__action = URI.parse(url_for({ controller: controller_name, action: @__action }.merge(@__request_params))).path
          end

          @__query_params.merge! ::Rack::Utils.parse_query URI.parse(@__action).query

          send("#{verb}_without_lurker", @__action, @__request_params, @__env)

          endpoint_path = explicit_path(@__example)

          return if endpoint_path.nil? # not lurker

          if inside_rails_controller_spec?
            if endpoint_path == true
              endpoint_path = path_regexp
            elsif endpoint_path.to_s.match(/^[^\/]/)
              endpoint_path = "#{path_regexp}-#{endpoint_path.gsub(/[^[[:alnum:]]]/, '_')}"
            end
          end

          if endpoint_path.blank?
            raise Lurker::ValidationError.new(<<-MSG.gsub(/^ {14}/, '')
              cannot determine path for .lurker, please, do it explicitly:
                it "tests", lurker: 'some-lurker-file-suffix' do
                  ...
                end
              MSG
            )
          end

          verify(verb, endpoint_path)
        end

        send :alias_method_chain, verb, :lurker
      end

      around do |example|
        wrapper(example)
      end
    end
  end
end

if defined?(RSpec)
  RSpec.configure do |config|
    config.include Lurker::RequestSpecWatcher, type: :request
  end
end
