require 'json'
require 'lurker'

module Lurker
  module ControllerSpecWatcher
    extend ActiveSupport::Concern
    include SpecWatcher

    included do
      # _describe = self # RSpec::ExampleGroups::... # class
      actions = [:get, :post, :put, :delete]
      if respond_to? :patch
        actions << :patch
      end
      actions.each do |verb|
        send(:define_method, "#{verb}_with_lurker") do |*params|
          @__action, @__request_params = params
          @__request_params ||= {}

          send("#{verb}_without_lurker", @__action, @__request_params)

          @__query_params = Hash[@__request_params.reject { |k,_| path_params.keys.include? k } .map do |k,v|
            [k.to_s, v.to_s]
          end]
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
    config.include Lurker::ControllerSpecWatcher, type: :controller
  end
end
