module Lurker
  module Json
    class Parser
      module Expertise
        module_function

        def type_defined?(hash)
          return false unless hash.is_a?(Hash)

          hash.key?(Json::TYPE) && Json::PRIMITIVES.include?(hash[Json::TYPE])
        end

        def type_supposed?(hash)
          return false unless hash.is_a?(Hash)

          hash.key?(Json::ANYOF) || hash.key?(Json::ALLOF) || hash.key?(Json::ONEOF) ||
          hash.key?(Json::ITEMS) || hash.key?(Json::PROPERTIES) ||
          hash.key?(Json::REF)
        end
      end
    end
  end
end
