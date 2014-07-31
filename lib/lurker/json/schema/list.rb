module Lurker
  module Json
    class List < Schema
      include Lurker::Json::Concerns::Validatable

      TYPE = 'type'.freeze
      ARRAY = 'array'.freeze
      ITEMS = 'items'.freeze

      def initialize(schema, options = {})
        @schema = {}
        initialize_properties

        super
      end

      def merge!(schema)
        @schema[ITEMS].merge!(schema)
      end

      def replace!(property, schema)
        @schema[ITEMS].replace!(property, schema)
      end

      private

      def parse_schema(schema)
        return if schema.empty?

        schema = schema.dup
        if schema.is_a?(Array)
          @schema[ITEMS] = @parser.typed.parse(schema.shift)

          schema.each { |payload| @schema[ITEMS].merge!(payload) }
        else
          @schema[ITEMS] = @parser.typed.parse(schema.delete(ITEMS))
          @schema.merge!(schema)
        end

        @schema
      end

      def initialize_properties
        @schema[TYPE] ||= ARRAY
        @schema[ITEMS] ||= {}
      end
    end
  end
end
