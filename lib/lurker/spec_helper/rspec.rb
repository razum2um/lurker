require 'lurker/spy'

if defined?(RSpec) && RSpec.respond_to?(:configure)
  when_tagged_with_lurker = { :lurker => lambda { |v| !!v } }

  RSpec.configure do |config|
    config.around(:each, when_tagged_with_lurker) do |ex|
      example = ex.respond_to?(:metadata) ? ex : ex.example
      options = example.metadata[:lurker]
      options = if options.is_a?(Hash)
        options.dup
      elsif options.is_a?(String)
        { suffix: options }
      else
        {}
      end
      Lurker::Spy.on(options, &example)
    end
  end
end
