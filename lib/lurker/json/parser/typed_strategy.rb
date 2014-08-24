module Lurker
  module Json
    class Parser
      class TypedStrategy
        include Lurker::Json::Parser::Expertise

        attr_reader :schema_options

        def initialize(options)
          options = options.dup

          @polymorph_if_empty = options.delete(:polymorph_if_empty)
          @schema_options = options
        end

        def parse(payload)
          case payload
          when Lurker::Json::Schema
            payload
          when Hash
            return create_by_type(payload) if type_defined?(payload)
            return create_by_supposition(payload) if type_supposed?(payload)
            return create_polymorph(payload) if polymorph_if_empty? && type_polymorph?(payload)

            Lurker::Json::Object.new(payload, schema_options)
          when Array
            return create_polymorph(payload) if polymorph_if_empty? && type_polymorph?(payload)

            Lurker::Json::List.new(payload, schema_options)
          else
            Lurker::Json::Attribute.new(payload, schema_options)
          end
        end

        private

        def create_by_supposition(payload)
          if payload.key?(Json::ITEMS)
            Lurker::Json::List.new(payload, schema_options)
          elsif payload.key?(Json::PROPERTIES)
            Lurker::Json::Object.new(payload, schema_options)
          elsif payload.key?(Json::ANYOF)
            Lurker::Json::Tuple::AnyOf.new(payload, schema_options)
          elsif payload.key?(Json::ALLOF)
            Lurker::Json::Tuple::AllOf.new(payload, schema_options)
          elsif payload.key?(Json::ONEOF)
            Lurker::Json::Tuple::OneOf.new(payload, schema_options)
          elsif payload.key?(Json::REF)
            Lurker::Json::Reference.new(payload, schema_options)
          else
            raise "Unknown type supposition for #{payload}"
          end
        end

        def create_by_type(payload)
          case payload[Json::TYPE]
          when Json::OBJECT
            Lurker::Json::Object.new(payload, schema_options)
          when Json::ARRAY
            Lurker::Json::List.new(payload, schema_options)
          else
            Lurker::Json::Attribute.new(payload, schema_options)
          end
        end

        def polymorph_if_empty?
          @polymorph_if_empty
        end

        def create_polymorph(payload)
          Lurker::Json::Polymorph.new(payload, schema_options)
        end
      end
    end
  end
end
