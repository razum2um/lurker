module Lurker
  module Json
    module Tuple
      class OneOf < Json::Schema
        include Tuple::InstanceMethods

        private

        def tuple_key
          Json::ONEOF
        end
      end
    end
  end
end
