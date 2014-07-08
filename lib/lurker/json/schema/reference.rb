module Lurker
  module Json
    class Reference < Schema
      REF = '$ref'.freeze

      delegate :merge!, :replace!, :reorder!, to: :@schema

      def to_original_hash(options = {})
        @original_schema.to_hash
      end

      private

      def parse_schema(schema)
        @original_schema = schema.dup

        # NOTE : We decide that reference is relative, so we are using merge
        # We use first read for correct relative path resolving
        reader = Lurker::Json::Reader.new(@uri.merge(schema[REF]).path)
        payload = reader.payload
        @schema = @parser.plain(uri: reader.path).parse(payload)

        # NOTE : The easiest way to get schema copy is to parse it again.
        # It's faster and reliable
        # @_schema = @parser.plain(uri: reader.path).parse(reader.payload)
        # @_schema_file = URI.parse(reader.path)
      end
    end
  end
end
