module Lurker
  module Json
    module Tuple
      module InstanceMethods
        def merge!(schema)
          return if exists?(schema)

          @schema[tuple_key] << @parser.typed.parse_property(
            parent_property, schema)
        end

        def replace!(schema)
          raise NotImplementedError
        end

        def exists?(schema)
          raise NotImplementedError
        end

        private

        def parse_schema(schema)
          @schema = {}
          initialize_properties

          schema = schema.dup
          @schema[tuple_key] = (schema.delete(tuple_key) || schema).map do |payload|
            @parser.typed.parse_property(parent_property, payload)
          end
        end

        def initialize_properties
          @schema[tuple_key] ||= []
        end
      end
    end
  end
end
