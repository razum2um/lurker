module Lurker
  module Json
    class Object < Schema
      def merge!(schema)
        unless schema.is_a?(Hash)
          raise TypeError, "Unable to merge #{schema.class} into JSON object"
        end

        schema.each do |property, property_schema|
          if @schema[Json::PROPERTIES].key?(property)
            @schema[Json::PROPERTIES][property].merge!(property_schema)
            next
          end

          replace!(property, property_schema)
        end
      end

      def replace!(property, property_schema)
        @schema[Json::PROPERTIES][property] = Lurker::Json::Parser.typed(subschema_options)
          .parse_property(property, property_schema)
      end

      private

      def initialize_default_properties
        @schema[Json::DESCRIPTION] ||= ''
        @schema[Json::TYPE] ||= Json::OBJECT
        @schema[Json::ADDITIONAL_PROPERTIES] = !!@schema[Json::ADDITIONAL_PROPERTIES]
        @schema[Json::REQUIRED] ||= []
        @schema[Json::PROPERTIES] ||= {}
      end

      def parse_schema(schema)
        @schema = {}

        schema = schema.dup
        if schema.key?(Json::PROPERTIES)
          @schema.merge!(schema)
        end

        initialize_default_properties

        (schema.delete(Json::PROPERTIES) || schema).each do |property, property_schema|
          @schema[Json::PROPERTIES][property] = @parser.typed.parse_property(
            property, property_schema)
        end
      end
    end
  end
end
