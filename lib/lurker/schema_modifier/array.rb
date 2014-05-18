module Lurker
  class SchemaModifier
    class Array
      def initialize(json_schema_hash)
        @array = json_schema_hash
      end

      def merge!(data)
        build_array

        data.each do |value|
          Lurker::SchemaModifier.merge!(@array["items"], value)
        end
      end

      def append!(data)
        @array << data
      end

      private

      def build_array
        @array["type"] ||= "array"
        @array["items"] ||= {}
      end
    end
  end
end
