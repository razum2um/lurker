module Lurker
  module Json
    module Tuple
      class AnyOf < Json::Schema
        include Tuple::InstanceMethods

        ANYOF = 'anyOf'.freeze

        private

        def tuple_key
          ANYOF
        end
      end
    end
  end
end
