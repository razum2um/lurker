module Lurker
  class ErbSchemaContext
    def allowed(*names)
      "Allowed values: #{names.join(', ')}"
    end

    def get_binding
      binding
    end
  end
end
