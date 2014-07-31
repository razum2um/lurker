module Lurker
  module Json
    class Writter
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
          Lurker::Json::Writter.write(reference, reference.original_uri.path)
        end
      end

      private

      # TODO : Separate schema dumping for JSON & YAML files
      def write_to_file(schema)
        FileUtils.mkdir_p(@dirname) unless File.directory?(@dirname)
        File.open(@path, File::WRONLY | File::TRUNC | File::CREAT) do |file|
          file.write(schema.to_yaml(reference: :original))
        end
      end

      def extract_references(schema, memo = [])
        schema.each do |_, object|
          if object.is_a?(Array)
            object.each { |x| extract_references(x, memo) }
          elsif object.is_a?(Hash) || object.is_a?(Lurker::Json::Schema)
            memo << object if object.is_a?(Lurker::Json::Reference)

            extract_references(object, memo)
          end
        end

        memo
      end
    end
  end
end
