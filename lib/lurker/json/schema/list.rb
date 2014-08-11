module Lurker
  module Json
    class List < Schema
      def merge!(schema)
        if schema.is_a?(Array)
          schema.each { |payload| @schema[Json::ITEMS].merge!(payload) }
        else
          @schema[Json::ITEMS].merge!(schema)
        end
      end

      def replace!(property, schema)
        if @schema[Json::ITEMS].is_a?(Lurker::Json::Attribute)
          @schema[Json::ITEMS] = schema
        else
          @schema[Json::ITEMS].replace!(property, schema)
        end
      end

      private

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        return if schema.empty?

        schema = schema.dup
        if schema.is_a?(Array)
          @schema[Json::ITEMS] = @parser.typed.parse(schema.shift)

          schema.each { |payload| @schema[Json::ITEMS].merge!(payload) }
        else
          @schema[Json::ITEMS] = @parser.typed.parse(schema.delete Json::ITEMS) if schema.key?(Json::ITEMS)
          @schema.merge!(schema)
        end

        @schema
      end

      def initialize_properties
        @schema[Json::TYPE] ||= Json::ARRAY
        @schema[Json::ITEMS] ||= []
      end
    end
  end
end
