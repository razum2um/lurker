require 'json-schema/validator'

module Lurker
  class Validator < JSON::Validator
    include JamlDescriptor::Rescue
  end
end
