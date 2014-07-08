module Lurker
  module Json
    class Writter
      PREFIX = 'prefix'.freeze
      ACTION = 'action'.freeze
      CONTROLLER = 'controller'.freeze
      EXTENSIONS = 'extensions'.freeze
      PATH_PARAMS = 'path_params'.freeze
      DESCRIPTION = 'description'.freeze
      DESCRPTIONS = {
        'index' => 'listing',
        'show' => '',
        'edit' => 'editing',
        'create' => 'creation',
        'update' => 'updating',
        'destroy' => 'descruction'
      }.freeze

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
        schema[DESCRIPTION] = schema_description(schema) if schema[DESCRIPTION].blank?
        schema[PREFIX] = schema_prefix(schema) if schema[PREFIX].blank?

        FileUtils.mkdir_p(@dirname) unless File.directory?(@dirname)
        File.open(@path, File::WRONLY|File::TRUNC|File::CREAT) do |file|
          file.write(schema.to_yaml(reference: :original))
        end
      end

      private

      def schema_prefix(schema)
        "#{extract_schema_subject(schema)} management"
      end

      def schema_description(schema)
        action = path_params(schema)[ACTION]

        "#{extract_schema_subject(schema).singularize} #{DESCRPTIONS[action]}".strip
      end

      def extract_schema_subject(schema)
        controller = path_params(schema)[CONTROLLER]

        "#{controller.to_s.split(/\//).last}"
      end

      def path_params(schema)
        schema[EXTENSIONS][PATH_PARAMS] || {}
      end

    end
  end
end
