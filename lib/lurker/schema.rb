require 'diffy'
require 'yaml'

module Lurker
  class Schema
    KEY = 'extensions'
    attr_reader :extensions

    def initialize(json_schema_hash, extensions={})
      @hash = json_schema_hash
      @extensions = if extensions.blank? && @hash.has_key?(KEY)
        @hash.delete(KEY)
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
      dirname = File.dirname(path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

      File.open(path, "w") do |file|
        YAML.dump(@hash.merge(
          KEY => @extensions
        ), file)
      end
    end

    protected

    def serialized_for_diff
      @serialized_for_diff ||= YAML.dump(@hash).each_line.map do |l|
        l unless l.match(/description|example/)
      end.compact.join
    end
  end
end
