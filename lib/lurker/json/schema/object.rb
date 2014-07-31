module Lurker
  module Json
    class Object < Schema
      include Lurker::Json::Concerns::Validatable

      TYPE = 'type'.freeze
      OBJECT = 'object'.freeze
      REQUIRED = 'required'.freeze
      PROPERTIES = 'properties'.freeze
      DESCRIPTION = 'description'.freeze
      ADDITIONAL_PROPERTIES = 'additionalProperties'.freeze

      def merge!(schema)
        unless schema.is_a?(Hash)
          return replace_with_new_type(schema) if @schema[PROPERTIES].blank?

          raise TypeError, "Unable to merge #{schema.class} into JSON object"
        end

        schema.each do |property, property_schema|
          if @schema[PROPERTIES].key?(property)
            @schema[PROPERTIES][property].merge!(property_schema)
            next
          end

          replace!(property, property_schema)
        end
      end

      def replace!(property, property_schema)
        @schema[PROPERTIES][property] = Lurker::Json::Parser.typed(subschema_options)
          .parse_property(property, property_schema)
      end

      private

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        schema = schema.dup
        merge_required = schema.key?(PROPERTIES)

        (schema.delete(PROPERTIES) || schema).each do |property, property_schema|
          @schema[PROPERTIES][property] = @parser.typed.parse_property(
            property, property_schema)
        end

        @schema.merge!(schema) if merge_required
      end

      def replace_with_new_type(schema)
        replace_options = {root_schema: root_schema, parent_schema: parent_schema,
                           parent_property: parent_property}

        new_schema = Lurker::Json::Parser.typed(replace_options).parse(schema)
        parent_schema.replace!(parent_property, new_schema)
      end

      def initialize_properties
        @schema[DESCRIPTION] ||= ''
        @schema[TYPE] ||= OBJECT
        @schema[ADDITIONAL_PROPERTIES] = !!@schema[ADDITIONAL_PROPERTIES]
        @schema[REQUIRED] ||= []
        @schema[PROPERTIES] ||= {}
      end
    end
  end
end
