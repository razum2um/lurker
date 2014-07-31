module Lurker
  module Json
    class Orderer
      EXTENSIONS = 'extensions'.freeze

      class << self
        def reorder(schema)
          new.reorder(schema)
        end
      end

      def reorder(schema)
        extensions = schema.delete(EXTENSIONS).try(:reorder!)
        schema.reorder!
        schema[EXTENSIONS] = extensions
      end
    end
  end
end
