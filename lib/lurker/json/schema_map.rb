module Lurker
  module Json
    class SchemaMap
      attr_reader :uri, :root_schema, :parent_schema, :parent_property
      delegate :to_hash, :to_json, :to_yaml, to: :schema_map

      def initialize(schema, options = {})
        @uri = schema.uri
        @root_schema = schema.root_schema
        @parent_schema = schema.parent_schema
        @parent_property = schema.parent_property

        @mapping = create_mapping(schema, options.fetch(:map_on))
      end

      def [](key)
        @mapping[key] ||= Lurker::Json::Polymorph.new(
          Hash.new,
          subschema_options.merge!(parent_schema: self, parent_property: key)
        )
      end

      def root?
        root_schema.blank?
      end

      def method_missing(method, *args, &block)
        if @mapping.respond_to?(method)
          return @mapping.send(method, *args, &block)
        end

        super
      end

      private

      def create_mapping(schema, keys)
        values = schema.respond_to?(:elements) ? schema.elements : [schema]
        Hash[keys.zip(values)]
      end

      def schema_map
        return Lurker::Json::Proxy.new(@mapping.values[0]) if @mapping.size == 1
        Lurker::Json::Tuple::OneOf.new(@mapping.values, subschema_options)
      end

      def subschema_options
        {
          uri: @uri,
          root_schema: @root_schema,
          parent_schema: @parent_schema,
          parent_property: @parent_property
        }
      end
    end
  end
end
