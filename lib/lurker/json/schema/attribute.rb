require 'action_dispatch'

module Lurker
  module Json
    class Attribute < Schema
      URI = 'uri'.freeze
      TYPE = 'type'.freeze
      COLOR = 'color'.freeze
      FORMAT = 'format'.freeze
      EXAMPLE = 'example'.freeze
      DATE_TIME = 'date-time'.freeze
      DESCRIPTION = 'description'.freeze

      TYPE_MAP = {
        'Time' => 'string',
        'Hash' => 'object',
        'Float' => 'number',
        'Fixnum' => 'integer',
        'NilClass' => 'null',
        'TrueClass' => 'boolean',
        'FalseClass' => 'boolean',
        'ActionDispatch::Http::UploadedFile' => 'string'
      }.freeze

      def merge!(schema)
        return replace!(schema) if @schema[TYPE].blank?

        schema = attributify(schema)
        return if eql?(schema)

        replace_options = {root_schema: root_schema, parent_schema: parent_schema,
          parent_property: parent_property}

        attributes_tuple = Lurker::Json::AttributesTuple.new(
          [to_hash, schema], replace_options)

        parent_schema.replace!(parent_property, attributes_tuple)
      end

      def replace!(schema)
        @schema.clear.merge!(attributify schema)
      end

      def eql?(schema)
        @schema[TYPE] == attributify(schema)[TYPE]
      end

      private

      def parse_schema(schema)
        @schema = {}
        initialize_properties

        if schema.is_a?(Hash)
          @schema.merge!(schema)
        else
          @schema = attributify(schema)
        end
      end

      def attributify(schema)
        return schema if schema.is_a?(Hash) || schema.is_a?(Lurker::Json::Schema)

        attribute = {
          DESCRIPTION => '',
          TYPE => guess_type(schema),
          EXAMPLE => serialize_example(schema)
        }

        if format = guess_format(schema)
          attribute[FORMAT] = format
        end

        attribute
      end

      def initialize_properties
        @schema[DESCRIPTION] ||= ''
        @schema[TYPE] ||= ''
        @schema[EXAMPLE] ||= ''
      end

      def serialize_example(data)
        if data.is_a?(ActionDispatch::Http::UploadedFile)
          data.headers
        else
          data
        end
      end

      def guess_type(data)
        data_type = data.class.to_s
        TYPE_MAP[data_type] || data_type.downcase
      end

      def guess_format(data)
        if data.is_a?(Time)
          DATE_TIME
        elsif data.is_a?(String)
          if data.start_with? 'http://'
            URI
          elsif data.match(/\#[0-9a-fA-F]{3}(?:[0-9a-fA-F]{3})?\b/)
            COLOR
          else
            begin
              DATE_TIME if Time.iso8601(data)
            rescue
              nil
            end
          end
        end
      end

    end
  end
end
