module Lurker
  module Json
    module Concerns
      module Validatable
        def validate(data)
          Lurker::Validator.new(to_validation_schema, data,
            record_errors: true).validate.map { |error| "- #{error}" }
        end

        def to_validation_schema
          set_additional_properties_false_on(to_hash).tap do |schema|
            if uri.class == URI::Generic
              schema[Json::ID] = uri.path
            else
              schema[Json::ID] = uri.to_s
            end
          end
        end

        private

        def set_additional_properties_false_on(object)
          case object
          when Hash
            copy = object.dup

            if object[Json::TYPE] == Json::OBJECT || object.key?(Json::PROPERTIES)
              copy[Json::ADDITIONAL_PROPERTIES] ||= false
            end

            object.each do |key, value|
              next if key == Json::ADDITIONAL_PROPERTIES
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
