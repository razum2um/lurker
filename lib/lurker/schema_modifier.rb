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
    end

    def append!
      schema_klass.new(@schema).append!(@data)
    end

    private

    def schema_klass
      klass_from_type(@schema)
    end

    def modifier_klass
      klass_from_type(@data)
    end

    def klass_from_type(anything)
      if anything.kind_of?(::Hash)
        Lurker::SchemaModifier::Hash
      elsif anything.kind_of?(::Array)
        Lurker::SchemaModifier::Array
      else
        Lurker::SchemaModifier::Atom
      end
    end
  end
end
