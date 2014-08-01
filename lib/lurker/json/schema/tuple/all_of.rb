module Lurker
  module Json
    module Tuple
      class AllOf < Json::Schema
        include Tuple::InstanceMethods

        ALLOF = 'allOf'.freeze

        private

        def tuple_key
          ALLOF
        end
      end
    end
  end
end
