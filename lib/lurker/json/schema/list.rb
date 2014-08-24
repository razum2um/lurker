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

      def initialize_properties
        @schema[Json::TYPE] ||= Json::ARRAY
        @schema[Json::ITEMS] ||= polymorph_items({})
      end

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        if schema_of_any_kind?(schema)
          @schema[Json::ITEMS] = polymorph_items(schema)
          return
        end

        schema = schema.dup
        if schema.is_a?(Array)
          @schema[Json::ITEMS] = @parser.typed.parse(schema.shift)

          schema.each { |payload| @schema[Json::ITEMS].merge!(payload) }
        else
          @schema[Json::ITEMS] = @parser.typed.parse(schema.delete Json::ITEMS) if schema.key?(Json::ITEMS)
          @schema.merge!(schema)
        end
      end

      def schema_of_any_kind?(schema)
        return true if schema.empty?
        return false unless schema.respond_to?(:key?) && schema.key?(Json::ITEMS)

        schema[Json::ITEMS].empty?
      end

      def polymorph_items(schema)
        options = subschema_options.merge!(parent_property: Json::ITEMS)
        Lurker::Json::Polymorph.new(schema, options)
      end
    end
  end
end
