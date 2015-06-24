module Lurker
  class FormBuilder < RenderingController
    def initialize(params)
      @_buffer = ''
      add_to_buffer(params)
    end

    def html
      @_buffer
    end

    private

    def add_to_buffer(params, parent_accessors = [])
      params.each do |name, value|

        accessors = parent_accessors.clone << name
        if value.is_a?(Hash)
          add_to_buffer(value, accessors)
        elsif value.is_a?(Array)
          value.each_with_index do |v, i|
            if v.is_a?(Hash)
              add_to_buffer(v, accessors << i)
            else
              add_element_to_buffer(accessors, v)
            end
          end
        else
          add_element_to_buffer(accessors, value)
        end
      end
    end

    def add_element_to_buffer(accessors, value)
      @_buffer += render(
        :partial => 'param_form_element',
        :locals => {
          :accessor => "#{accessors.compact.join('.')}",
          :label => "#{print_labels(accessors)}",
          :label_text => "#{print_labels(accessors)}",
          :value => value
        }
      )
    end

    def print_labels(accessors)
      accessors.inject do |acc, label|
        if label.is_a? Numeric
          "#{acc}[]"
        else
          "#{acc}[#{label}]"
        end
      end
    end
  end
end
