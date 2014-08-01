module Lurker
  module Json
    module Tuple
      class OneOf < Json::Schema
        include Tuple::InstanceMethods

        ONEOF = 'oneOf'.freeze

        private

        def tuple_key
          ONEOF
        end
      end
    end
  end
end
