module Lurker
  module Json
    class Parser
      class PlainStrategy
        include Lurker::Json::Parser::Expertise

        attr_reader :schema_options

        def initialize(options)
          @schema_options = options.dup
        end

        def parse(payload)
          case payload
          when Lurker::Json::Schema
            payload
          when Hash
            return parse_as_typed(payload) if type_defined?(payload) ||
              type_supposed?(payload)

            Lurker::Json::Schema.new(payload, schema_options)
          when Array
            payload.map do |schema|
              Lurker::Json::Parser.plain(schema_options).parse(schema)
            end
          else
            payload
          end
        end

        private

        def parse_as_typed(payload)
          Lurker::Json::Parser.typed(schema_options).parse(payload)
        end
      end
    end
  end
end
