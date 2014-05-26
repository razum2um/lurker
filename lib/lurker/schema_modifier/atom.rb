module Lurker
  class SchemaModifier
    class Atom
      TYPE_MAP = {
        "ActionDispatch::Http::UploadedFile" => "string",
        "Fixnum" => "integer",
        "Float" => "number",
        "Hash" => "object",
        "Time" => "string",
        "TrueClass" => "boolean",
        "FalseClass" => "boolean",
        "NilClass" => "null"
      }.freeze

      DATE_TIME_FORMAT = "date-time".freeze
      COLOR_FORMAT = "color".freeze
      URI_FORMAT = "uri".freeze

      def initialize(json_schema_hash)
        @atom = json_schema_hash
      end

      def merge!(data)
        atom = build_atom(data)
        combined? ? append_new(atom) : combine_with(atom)
      end

      private

      def combine_with(atom)
        return @atom.clear.merge!(atom) unless @atom.key?("type")

        if @atom["type"] != atom["type"]
          existing_atom = JsonSchemaHash === @atom ? @atom.to_h : @atom.dup
          @atom.clear
          @atom["anyOf"] = [existing_atom, atom]
        end
      end

      def append_new(atom)
        # TODO : If example empty - fill from duplicate
        return if !!@atom["anyOf"].detect { |atm| atm["type"] == atom["type"] }

        @atom["anyOf"] << atom
      end

      def combined?
        !!@atom["anyOf"]
      end

      def build_atom(data)
        atom = {
          "description" => "",
          "type" => guess_type(data),
          "example" => serialize_example(data)
        }

        if format = guess_format(data)
          atom["format"] = format
        end

        atom
      end

      def serialize_example(data)
        if data.is_a?(ActionDispatch::Http::UploadedFile)
          data.headers
        else
          data
        end
      end

      def guess_type(data)
        in_type = data.class.to_s
        TYPE_MAP[in_type] || in_type.downcase
      end

      def guess_format(data)
        if data.kind_of?(Time)
          DATE_TIME_FORMAT
        elsif data.kind_of?(String)
          if data.start_with? "http://"
            URI_FORMAT
          elsif data.match(/\#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?\b/)
            COLOR_FORMAT
          else
            begin
              DATE_TIME_FORMAT if Time.iso8601(data)
            rescue
              nil
            end
          end
        end
      end
    end # class Atom
  end
end
