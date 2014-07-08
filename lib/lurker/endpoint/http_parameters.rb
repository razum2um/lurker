module Lurker
  class Endpoint
    class HttpParameters
      extend Forwardable
      include Lurker::Utils

      ID = 'id'.freeze
      TYPE = 'type'.freeze
      OBJECT = 'object'.freeze
      PROPERTIES = 'properties'.freeze
      ADDITIONAL_PROPERTIES = 'additionalProperties'.freeze

      delegate [:[], :key?, :keys, :empty?] => :http_parameters

      attr_reader :errors

      def initialize(schema, options = {})
        @schema = schema

        @schema_key = options.fetch(:schema_key)
        @schema_id = options.fetch(:schema_id)
        @human_name = options.fetch(:human_name, @schema_key)

        @schema[@schema_key] ||= {}
        @errors = []
      end

      def add(parameters)
        @schema[@schema_key] = Lurker::SchemaModifier.merge!(
          Lurker::JsonSchemaHash.new(http_parameters, @schema_id), stringify_keys(parameters)
        ).to_h
      end

      # TODO : Split the collecting of errors and representations of errors
      def validate(parameters)
        errors = Lurker::Validator.new(schemify(http_parameters), stringify_keys(parameters),
          record_errors: true).validate

        @errors = errors.map { |error| "- #{error}" }
        @errors.unshift(@human_name) unless @errors.empty?
      end

      private

      def http_parameters
        @schema[@schema_key]
      end

      def schemify(object)
        set_additional_properties_false_on(object).tap do |schema|
          schema[ID] = "file://#{@schema_id}"
        end
      end

      def set_additional_properties_false_on(object)
        if object.is_a? Hash
          copy = object.dup

          if object[TYPE] == OBJECT || object.key?(PROPERTIES)
            copy[ADDITIONAL_PROPERTIES] ||= false
          end

          object.each do |key, value|
            next if key == ADDITIONAL_PROPERTIES
            copy[key] = set_additional_properties_false_on(value)
          end

          copy
        elsif object.is_a? Array
          copy = object.map { |value| set_additional_properties_false_on(value) }
        else
          object
        end
      end
    end
  end
end
