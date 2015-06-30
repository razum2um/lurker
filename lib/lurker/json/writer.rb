module Lurker
  module Json
    class Writer
      class << self
        def write(schema, path)
          new(path).write(schema)
        end
      end

      def initialize(path)
        @path = path
        @dirname = File.dirname(path)
      end

      def write(schema)
        write_to_file(schema)

        extract_references(schema).each do |reference|
          Lurker::Json::Writer.write(reference, reference.original_uri.path)
        end
      end

      private

      # TODO : Separate schema dumping for JSON & YAML files
      def write_to_file(schema)
        FileUtils.mkdir_p(@dirname) unless File.directory?(@dirname)
        File.open(@path, File::WRONLY | File::TRUNC | File::CREAT) do |file|
          file.write(present_by_extension schema)
        end
      end

      def extract_references(schema, memo = [])
        case schema
        when Array
          schema.each { |payload| extract_references(payload, memo) }
        when Hash, Lurker::Json::Schema
          schema.each do |_, payload|
            memo << payload if payload.is_a?(Lurker::Json::Reference)
            extract_references(payload, memo)
          end
        else
          # no-op
        end

        memo
      end

      def present_by_extension(schema)
        case File.extname(@path)
        when '.yml' then schema.to_yaml(reference: :original)
        when '.json' then JSON.pretty_generate(schema.to_hash reference: :original)
        else raise TypeError, "Unknown schema file extension '#{File.extname(@path)}'"
        end
      end
    end
  end
end
