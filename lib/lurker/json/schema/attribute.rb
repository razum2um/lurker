require 'action_dispatch'

module Lurker
  module Json
    class Attribute < Schema
      URI = 'uri'.freeze
      COLOR = 'color'.freeze
      FORMAT = 'format'.freeze
      DATE_TIME = 'date-time'.freeze

      TYPE_MAP = {
        'Time' => Json::STRING,
        'Hash' => Json::OBJECT,
        'Float' => Json::NUMBER,
        'Fixnum' => Json::INTEGER,
        'NilClass' => Json::NULL,
        'TrueClass' => Json::BOOLEAN,
        'FalseClass' => Json::BOOLEAN,
        'ActionDispatch::Http::UploadedFile' => Json::STRING
      }.freeze

      def merge!(schema)
        return replace!(schema) if @schema[Json::TYPE].blank?

        schema = attributify(schema)
        return if eql?(schema)

        replace_options = {root_schema: root_schema, parent_schema: parent_schema,
                           parent_property: parent_property}

        attributes_tuple = Lurker::Json::Tuple::AnyOf.new(
          [to_hash, schema], replace_options)

        parent_schema.replace!(parent_property, attributes_tuple)
      end

      def replace!(schema)
        @schema.clear.merge!(attributify schema)
      end

      def eql?(schema)
        @schema[Json::TYPE] == attributify(schema)[Json::TYPE]
      end

      private

      def initialize_default_properties
        @schema[Json::DESCRIPTION] ||= ''
        @schema[Json::TYPE] ||= ''
        @schema[Json::EXAMPLE] = '' if @schema[Json::EXAMPLE].nil?
      end

      def parse_schema(schema)
        @schema = {}

        if schema.is_a?(Hash)
          @schema.merge!(schema)
        else
          @schema = attributify(schema)
        end

        initialize_default_properties
      end

      def attributify(schema)
        return schema if schema.is_a?(Hash) || schema.is_a?(Lurker::Json::Schema)

        attribute = {
          Json::DESCRIPTION => '',
          Json::TYPE => guess_type(schema),
          Json::EXAMPLE => serialize_example(schema)
        }

        if format = guess_format(schema)
          attribute[FORMAT] = format
        end

        attribute
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
