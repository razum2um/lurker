module Lurker
  module Json
    module Tuple
      class AnyOf < Json::Schema
        include Tuple::InstanceMethods

        private

        def tuple_key
          Json::ANYOF
        end
      end
    end
  end
end
