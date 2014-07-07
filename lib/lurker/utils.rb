module Lurker
  module Utils
    module_function

    def stringify_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), memo|
          memo[key.to_s] = stringify_keys(value)
        end
      when Array
        object.map { |value| stringify_keys(value) }
      else
        object
      end
    end

  end
end
