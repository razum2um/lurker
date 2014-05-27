require 'lurker/spy'

if defined?(RSpec) && RSpec.respond_to?(:configure)
  RSpec.configure do |config|

    lurker = ->(example) {
      # RSpec::Core::ExampleGroup::Nested_1 === self
      @_example = example

      if (metadata = example.metadata[:lurker]).present?
        Lurker::Spy.on(suffix: metadata, &example)
      else
        example.call
      end
    }

    config.around(:each, type: :controller, &lurker)
    config.around(:each, type: :request, &lurker)
  end
end
