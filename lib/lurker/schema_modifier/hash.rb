module Lurker
  class SchemaModifier
    class Hash
      def initialize(json_schema_hash)
        @hash = json_schema_hash
      end

      def merge!(data)
        build_hash

        data.each do |name, value|
          unless @hash[name]
            @hash["properties"][name] ||= {}
            Lurker::SchemaModifier.merge!(@hash["properties"][name], value)
          end
        end
      end

      private

      def build_hash
        @hash["description"] ||= ""
        @hash["type"] ||= "object"
        @hash["additionalProperties"] = false if @hash["additionalProperties"].nil?
        @hash["required"] ||= []
        @hash["properties"] ||= {}
      end
    end
  end
end
