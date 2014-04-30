require 'diffy'
require 'yaml'

module Lurker
  class Schema
    KEY = 'extensions'
    DESCRPTIONS = {
      'index' => 'listing',
      'show' => '',
      'edit' => 'editing',
      'create' => 'creation',
      'update' => 'updating',
      'destroy' => 'descruction'
    }
    attr_reader :extensions

    def initialize(json_schema_hash, extensions={})
      @hash = json_schema_hash
      @extensions = if extensions.blank? && @hash.has_key?(KEY)
        @hash.delete(KEY) || {}
      else
        extensions
      end
    end

    def respond_to_missing?(method, include_private = false)
      @hash.send(:respond_to_missing?, method, include_private)
    end

    def method_missing(method, *args, &block)
      @hash.send method, *args, &block
    end

    def diff(schema)
      ::Diffy::Diff.new(
        schema.serialized_for_diff,
        serialized_for_diff,
        context: 1).to_s(:color)
    end

    def write_to(path)
      if @hash['prefix'].blank?
        @hash['prefix'] = "#{default_subject} management"
      end
      if @hash['description'].blank?
        @hash['description'] = default_descrption.strip
      end

      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      File.open(path, "w") do |file|
        file.write(YAML.dump(Hash[@hash.sort].merge(
          KEY => Hash[@extensions.sort]
        )))
      end
    end

    protected

    def serialized_for_diff
      @serialized_for_diff ||= YAML.dump(@hash).each_line.map do |l|
        l unless l.match(/description|example/)
      end.compact.join
    end

    private

    def default_descrption
      "#{default_subject.singularize} #{DESCRPTIONS[path_params['action']]}"
    end

    def default_subject
      "#{path_params['controller'].to_s.split(/\//).last}"
    end

    def path_params
      @extensions['path_params'] || {}
    end
  end
end
