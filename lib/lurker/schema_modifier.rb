module Lurker
  class SchemaModifier
    class << self
      def merge!(schema, data)
        new(schema, data).merge!
      end

      def append!(schema, data)
        new(schema, data).append!
      end
    end

    def initialize(schema, data)
      @schema = schema
      @data = data
    end

    def merge!
      modifier_klass.new(@schema).merge!(@data)
      @schema
    end

    def append!
      schema_klass.new(@schema).append!(@data)
      @schema
    end

    private

    def schema_klass
      klass_from_type(@schema)
    end

    def modifier_klass
      klass_from_type(@data)
    end

    def klass_from_type(anything)
      if anything.is_a?(::Hash)
        Lurker::SchemaModifier::Hash
      elsif anything.is_a?(::Array)
        Lurker::SchemaModifier::Array
      else
        Lurker::SchemaModifier::Atom
      end
    end
  end
end
