module Lurker
  module Json
    # NOTE : Primary usecase - wrap Lurker::Json::Schema descendants to delegate
    # to_hash|to_json|to_yaml methods to parent class Lurker::Json::Schema insted
    class Proxy < Schema
      def parse_schema(schema)
        @schema = schema
      end
      private :parse_schema
    end
  end
end
