require 'json'

module Lurker
  class Spy
    attr_reader :block, :service, :request, :response

    extend Forwardable
    delegate [:verb, :endpoint_path, :payload] => :request
    delegate [:verb=, :endpoint_path=, :payload=] => :request
    delegate [:status, :body, :extensions] => :response
    delegate [:status=, :body=, :extensions=] => :response

    def initialize(options={}, &block)
      @options = options
      @block = block

      @request = Request.new
      @response = Response.new
      @service = if defined?(Rails)
        Service.new(Rails.root.join(DEFAULT_SERVICE_PATH).to_s, Rails.application.class.parent_name)
      else
        Service.default_service
      end
    end

    %w[payload body extensions].each do |meth|
      define_method "#{meth}_with_jsonify=" do |value|
        value = JSON.parse(value) if value.is_a? String
        value.stringify_keys! if value.is_a? Hash
        send "#{meth}_without_jsonify=", value
      end
      alias_method_chain "#{meth}=", :jsonify
    end

    def call
      @block.call.tap do |result|
        @service.verify!(
          verb, endpoint_path, payload,
          extensions, status, body
        )

        @service.persist! if success?(result)
      end
    ensure
      # recover methods
    end

    def success?(result)
      if defined?(::Minitest::Test) && result.is_a?(::Minitest::Test)
        result.failure.nil?
      elsif result.is_a?(Exception)
        false
      else
        result
      end
    end
    private :success?

    def self.on(options={}, &block)
      (Thread.current[:lurker_spy] ||= new(options, &block)).tap do |spy|
        spy.call
      end
    end

    def self.current
      Thread.current[:lurker_spy]
    end
  end
end
