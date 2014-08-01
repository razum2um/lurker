module Lurker
  module Json
    class List < Schema
      TYPE = 'type'.freeze
      ARRAY = 'array'.freeze
      ITEMS = 'items'.freeze

      def merge!(schema)
        if schema.is_a?(Array)
          schema.each { |payload| @schema[ITEMS].merge!(payload) }
        else
          @schema[ITEMS].merge!(schema)
        end
      end

      def replace!(property, schema)
        if @schema[ITEMS].is_a?(Lurker::Json::Attribute)
          @schema[ITEMS] = schema
        else
          @schema[ITEMS].replace!(property, schema)
        end
      end

      private

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        return if schema.empty?

        schema = schema.dup
        if schema.is_a?(Array)
          @schema[ITEMS] = @parser.typed.parse(schema.shift)

          schema.each { |payload| @schema[ITEMS].merge!(payload) }
        else
          @schema[ITEMS] = @parser.typed.parse(schema.delete ITEMS) if schema.key?(ITEMS)
          @schema.merge!(schema)
        end

        @schema
      end

      def initialize_properties
        @schema[TYPE] ||= ARRAY
        @schema[ITEMS] ||= []
      end
    end
  end
end
