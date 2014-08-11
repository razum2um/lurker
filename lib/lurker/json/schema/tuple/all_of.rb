module Lurker
  module Json
    module Tuple
      class AllOf < Json::Schema
        include Tuple::InstanceMethods

        private

        def tuple_key
          Json::ALLOF
        end
      end
    end
  end
end
