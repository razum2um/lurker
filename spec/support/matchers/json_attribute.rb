require 'rspec/expectations'

RSpec::Matchers.define :be_a_json_attribute do
  match do |attribute|
    expect(attribute).to have_key 'type'

    expect(attribute['type']).to eq @type if @type.present?
    expect(attribute['example']).to eq @example if @example.present?

    true
  end

  chain :with_type do |type|
    @type = type
  end

  chain :with_example do |example|
    @example = example
  end

  failure_message_for_should do |attribute|
    "expected that #{attribute.try(:to_hash) || attribute} to be a json attribute".tap do |message|
      message << " with type '#{@type}'" if @type.present?
      message << " with example '#{@example}'"  if @example.present?
    end
  end
end
