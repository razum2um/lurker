module Lurker
  module Json
    class Schema
      include Lurker::Json::Concerns::Validatable

      EXTENSIONS = 'extensions'.freeze
      RESPONSE_CODES = 'responseCodes'.freeze
      REQUEST_PARAMETERS = 'requestParameters'.freeze
      RESPONSE_PARAMETERS = 'responseParameters'.freeze

      attr_reader :uri, :root_schema, :parent_schema, :parent_property

      def initialize(schema, options = {})
        @root_schema = options[:root_schema]
        @parent_schema = options[:parent_schema]
        @parent_property = options[:parent_property]
        @uri = parse_uri(options[:uri])

        @parser = Lurker::Json::Parser.new(subschema_options)

        parse_schema(schema)
      end

      def documentation_uri(extension = 'md')
        @uri.to_s.sub(%r{^file:(//)?}, '').sub(/(\.json)?(\.yml)?(\.erb)?$/, ".#{extension}")
      end

      def documentation
        open(documentation_uri).read
      rescue
        @schema['description']
      end

      def root?
        root_schema.blank?
      end

      def merge!(schema)
        return if schema.blank?

        schema.each do |property, property_schema|
          if @schema[property].is_a?(Lurker::Json::Schema)
            @schema[property].merge!(property_schema)

            next
          end

          replace!(property, property_schema)
        end
      end

      def replace!(property, property_schema)
        @schema[property] = @parser.plain.parse_property(property, property_schema)
      end

      def reorder!
        @schema = Hash[@schema.sort]
        self
      end

      def to_hash(options = {})
        hashify(@schema, options)
      end

      def to_json(options = {})
        to_hash(options).to_json
      end

      def to_yaml(options = {})
        YAML.dump(to_hash(options))
      end

      def method_missing(method, *args, &block)
        if @schema.is_a?(Lurker::Json::Schema) || @schema.respond_to?(method)
          return @schema.send(method, *args, &block)
        end

        super
      end

      private

      def hashify(object, options = {})
        case object
        when Lurker::Json::Reference
          options[:reference] == :original ? object.to_original_hash(options)
            : object.to_hash(options)
        when Lurker::Json::Schema then object.to_hash(options)
        when Array then object.map { |x| hashify(x, options) }
        when Hash
          object.each_with_object({}) do |(property, property_schema), memo|
            memo[property] = hashify(property_schema, options)
          end
        else object
        end
      end

      def parse_uri(uri)
        return if uri.blank?

        uri = uri.respond_to?(:scheme) ? uri : URI.parse(uri)
        uri.relative? ? URI.parse("file://#{uri}") : uri
      end

      def parse_schema(schema)
        @schema = {}

        unless schema.is_a?(Hash)
          return @schema = @parser.plain.parse(schema)
        end

        schema.each do |property, property_schema|
          @schema[property] = case property
          when EXTENSIONS
            Lurker::Json::Extensions.new(property_schema, subschema_options)
          when RESPONSE_CODES
            Lurker::Json::ResponseCodes.new(property_schema, subschema_options)
          when REQUEST_PARAMETERS, RESPONSE_PARAMETERS
            @parser.typed(polymorph_if_empty: true).parse_property(property, property_schema)
          else
            @parser.plain.parse_property(property, property_schema)
          end
        end
      end

      def subschema_options
        {uri: uri, root_schema: (root? ? self : root_schema), parent_schema: self}
      end
    end
  end
end
