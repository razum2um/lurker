module Lurker
  module Json
    module Concerns
      module Validatable
        ID = 'id'.freeze
        TYPE = 'type'.freeze
        OBJECT = 'object'.freeze
        PROPERTIES = 'properties'.freeze
        ADDITIONAL_PROPERTIES = 'additionalProperties'.freeze

        def validate(data)
          Lurker::Validator.new(to_validation_schema, data,
            record_errors: true).validate.map { |error| "- #{error}" }
        end

        def to_validation_schema
          set_additional_properties_false_on(to_hash).tap do |schema|
            schema[ID] = "file://#{uri}"
          end
        end

        private

        def set_additional_properties_false_on(object)
          case object
          when Hash
            copy = object.dup

            if object[TYPE] == OBJECT || object.key?(PROPERTIES)
              copy[ADDITIONAL_PROPERTIES] ||= false
            end

            object.each do |key, value|
              next if key == ADDITIONAL_PROPERTIES
              copy[key] = set_additional_properties_false_on(value)
            end

            copy
          when Array
            copy = object.map { |value| set_additional_properties_false_on(value) }
          else object
          end
        end
      end
    end
  end
end
