require 'json'

module Lurker
  class Spy
    class BlindError < StandardError; end

    attr_reader :block, :service
    attr_accessor :request, :response

    extend Forwardable
    delegate [:verb, :payload] => :request
    delegate [:status, :body] => :response

    def initialize(options={}, &block)
      @options = options
      @block = block

      @service = if defined?(Rails)
        rails_app_class = Rails.application.class
        rails_app_name = rails_app_class.respond_to?(:module_parent_name) ? rails_app_class.module_parent_name : rails_app_class.parent_name
        Service.new(Rails.root.join(DEFAULT_SERVICE_PATH).to_s, rails_app_name)
      else
        Service.default_service
      end
    end

    def call
      @request = @response = nil # fill in while test
      @block.call.tap do |result|
        if @request && @response
          @service.verify!(
            verb, endpoint_path, payload,
            extensions, status, body
          )

          @service.persist! if success?(result)
        end
      end
    end

    def endpoint_path
      [request.endpoint_path, suffix].compact.join('-')
    end

    def extensions
      extensions = {
        path_params: reordered_request_path_params,
        path_info: request.path_info,
        method: request.verb,
      }
      unless request.query_params.empty?
        extensions[:query_params] = request.query_params
      end
      if suffix.present?
        extensions[:suffix] = suffix.to_s
      end
      extensions.stringify_keys
    end

    def suffix
      if (suffix = @options[:suffix]).is_a?(String)
        suffix.gsub(/[^[[:alnum:]]]/, '_')
      end
    end

    def success?(result)
      if defined?(::Minitest::Test) && result.is_a?(::Minitest::Test)
        result.failure.nil?
      elsif result.is_a?(Exception)
        false
      else
        true
      end
    end
    private :success?

    def self.on(options={}, &block)
      require 'lurker/spec_helper' unless defined? Lurker::SpecHelper
      instance = new(options, &block)
      Thread.current[:lurker_spy] = instance
      instance.call
    ensure
      Thread.current[:lurker_spy] = nil
    end

    def self.enabled?
      current.present?
    end

    def self.current
      Thread.current[:lurker_spy]
    end

    private

    def reordered_request_path_params
      other_params = request.path_params.reject do |k, _|
        k == 'controller' || k == 'action'
      end

      {
        'controller' => request.path_params['controller'],
        'action' => request.path_params['action']
      }.merge!(other_params)
    end
  end
end

