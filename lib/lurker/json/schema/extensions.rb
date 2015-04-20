module Lurker
  module Json
    class Extensions < Schema
      EXTENSIONS = 'extensions'.freeze

      def initialize(schema, options = {})
        @parent_property = EXTENSIONS
        super
      end

      def merge!(schema)
        return unless Lurker.rewrite?
        @schema = @parser.plain.parse_property(parent_property, schema)
      end
    end
  end
end
