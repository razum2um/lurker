module Lurker
  module Json
    class Polymorph < Schema
      def merge!(schema)
        case parent_schema
        when Lurker::Json::Object
          parent_schema[Json::PROPERTIES][parent_property] = @parser.typed.parse(schema)
        when Lurker::Json::List
          if schema.is_a?(Array)
            return if schema.empty?

            schema = schema.dup
            parent_schema[Json::ITEMS] = @parser.typed.parse(schema.shift)
            parent_schema.merge!(schema)
          else
            parent_schema[Json::ITEMS] = @parser.typed.parse(schema)
          end
        else
          parent_schema[parent_property] = @parser.typed.parse(schema)
        end
      end

      def replace!(property, schema)
        morph = Lurker::Json::Object.new({}, subschema_options)

        case parent_schema
        when Lurker::Json::Object
          parent_schema[Json::PROPERTIES][parent_property] = morph
          parent_schema.replace!(property, schema)
        when Lurker::Json::List
          parent_schema[Json::ITEMS] = morph
          parent_schema.replace!(property, schema)
        else
          parent_schema[parent_property] = morph
          parent_schema.replace!(property, schema)
        end
      end

      private

      def parse_schema(schema)
        @schema = schema
      end

      # NOTE : The parser will ref to parent_schema instead
      def subschema_options
        {uri: parent_schema.uri,
         root_schema: parent_schema.root? ? parent_schema : parent_schema.root_schema,
         parent_schema: parent_schema,
         parent_property: parent_property}
      end
    end
  end
end
