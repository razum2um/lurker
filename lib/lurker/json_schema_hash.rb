module Lurker
  class JsonSchemaHash
    include JamlDescriptor::Rescue

    def initialize(schema_hash, uri)
      @to_s = uri
      @uri = URI.parse(uri)
      @uri = URI.parse("file://#{uri}") if @uri.relative?

      @schema_hash = Hash[schema_hash.map do |k,v|
        if k == '$ref' && v.is_a?(String)
          uri = @uri.merge(v)
          schema_hash = JSON.parse(open(uri.to_s).read)
          [k, JsonSchemaHash.new(schema_hash, uri.to_s)]
        elsif v.is_a?(Hash)
          [k, JsonSchemaHash.new(v, @to_s)]
        else
          [k, v]
        end
      end]
    end

    def respond_to_missing?(method, include_private = false)
      @schema_hash.send(:respond_to_missing?, method, include_private)
    end

    def method_missing(method, *args, &block)
      @schema_hash.send method, *args, &block
    end

    def is_a?(*args)
      @schema_hash.is_a?(*args)
    end
  end
end
