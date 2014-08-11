module Lurker
  module Json
    NULL = 'null'.freeze
    ARRAY = 'array'.freeze
    STRING = 'string'.freeze
    OBJECT = 'object'.freeze
    NUMBER = 'number'.freeze
    BOOLEAN = 'boolean'.freeze
    INTEGER = 'integer'.freeze

    PRIMITIVES = [NULL, BOOLEAN, INTEGER, NUMBER, STRING, ARRAY, OBJECT].freeze

    ID = 'id'.freeze
    REF = '$ref'.freeze
    TYPE = 'type'.freeze
    ITEMS = 'items'.freeze
    EXAMPLE = 'example'.freeze
    REQUIRED = 'required'.freeze
    PROPERTIES = 'properties'.freeze
    DESCRIPTION = 'description'.freeze
    ADDITIONAL_PROPERTIES = 'additionalProperties'.freeze

    ANYOF = 'anyOf'.freeze
    ALLOF = 'allOf'.freeze
    ONEOF = 'oneOf'.freeze
  end
end
