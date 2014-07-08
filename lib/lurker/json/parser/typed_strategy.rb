module Lurker
  module Json
    class Parser
      class TypedStrategy
        include Lurker::Json::Parser::Expertise

        ANYOF = 'anyOf'.freeze
        ITEMS = 'items'.freeze
        TYPE  = 'type'.freeze
        ARRAY = 'array'.freeze
        OBJECT = 'object'.freeze
        PROPERTIES = 'properties'.freeze

        attr_reader :schema_options

        def initialize(options)
          @schema_options = options.dup
        end

        def parse(payload)
          case payload
          when Lurker::Json::Schema
            payload
          when Hash
            return create_by_type(payload) if type_defined?(payload)
            return create_by_supposition(payload) if type_supposed?(payload)

            Lurker::Json::Object.new(payload, schema_options)
          when Array
            Lurker::Json::List.new(payload, schema_options)
          else
            Lurker::Json::Attribute.new(payload, schema_options)
          end
        end

        private

        def create_by_supposition(payload)
          if payload.key?(ITEMS)
            Lurker::Json::List.new(payload, schema_options)
          elsif payload.key?(PROPERTIES)
            Lurker::Json::Object.new(payload, schema_options)
          elsif payload.key?(ANYOF)
            Lurker::Json::AttributesTuple.new(payload, schema_options)
          elsif payload.key?(REF)
            Lurker::Json::Reference.new(payload, schema_options)
          else
            raise "Unknown type supposition for #{payload}"
          end
        end

        def create_by_type(payload)
          case payload[TYPE]
          when OBJECT
            Lurker::Json::Object.new(payload, schema_options)
          when ARRAY
            Lurker::Json::List.new(payload, schema_options)
          else
            Lurker::Json::Attribute.new(payload, schema_options)
          end
        end

      end
    end
  end
end
