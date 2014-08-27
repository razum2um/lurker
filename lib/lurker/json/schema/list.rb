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

      def initialize_default_properties(empty_items = {})
        @schema[Json::TYPE] ||= Json::ARRAY
        @schema[Json::ITEMS] ||= polymorph_items(empty_items)
      end

      def parse_schema(schema)
        @schema = {}
        schema.is_a?(Array) ? parse_array(schema.dup) : parse_hash(schema.dup)
      end

      def parse_array(schema)
        initialize_default_properties([])
        return if schema.empty?

        @schema[Json::ITEMS] = @parser.typed.parse(schema.shift)
        schema.each { |payload| @schema[Json::ITEMS].merge!(payload) }
      end

      def parse_hash(schema)
        @schema.merge!(schema)
        @schema[Json::ITEMS] = @parser.typed(polymorph_if_empty: true)
          .parse(schema.delete(Json::ITEMS) || schema)

        initialize_default_properties
      end

      def polymorph_items(schema)
        options = subschema_options.merge!(parent_property: Json::ITEMS)
        Lurker::Json::Polymorph.new(schema, options)
      end
    end
  end
end
