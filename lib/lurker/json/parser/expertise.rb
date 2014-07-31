module Lurker
  module Json
    class Parser
      module Expertise
        REF = '$ref'.freeze
        TYPE = 'type'.freeze
        ANYOF = 'anyOf'.freeze
        ITEMS = 'items'.freeze
        PROPERTIES = 'properties'.freeze

        module_function

        def type_defined?(hash)
          return false unless hash.is_a?(Hash)

          hash.key? TYPE
        end

        def type_supposed?(hash)
          return false unless hash.is_a?(Hash)

          hash.key?(ANYOF) || hash.key?(ITEMS) ||
            hash.key?(PROPERTIES) || hash.key?(REF)
        end
      end
    end
  end
end
