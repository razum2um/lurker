module Lurker
  module Json
    class AttributesTuple < Schema
      ANYOF = 'anyOf'.freeze

      def merge!(schema)
        return if exists?(schema)

        @schema[ANYOF] << @parser.typed.parse_property(
          parent_property, schema)
      end

      def exists?(schema)
        attribute = Lurker::Json::Attribute.new(schema)

        @schema[ANYOF].any? { |atr| atr.eql?(attribute) }
      end

      private

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        schema = schema.dup
        @schema[ANYOF] = (schema.delete(ANYOF) || schema).map do |payload|
          @parser.typed.parse_property(parent_property, payload)
        end
      end

      def initialize_properties
        @schema[ANYOF] ||= []
      end
    end
  end
end
