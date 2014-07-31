require 'rspec/expectations'

RSpec::Matchers.define :be_a_json_object do
  @properties = []

  match do |object|
    expect(object).to have_key 'type'
    expect(object).to have_key 'properties'
    expect(object['type']).to eq 'object'

    if @properties.present?
      @properties.each do |property|
        expect(object['properties']).to have_key property
      end
    end

    true
  end

  chain :with_properties do |*properties|
    @properties |= properties
  end

  chain :with_property do |property|
    @properties << property
  end

  failure_message_for_should do |object|
    "expected that #{object.try(:to_hash) || object} to be a json object".tap do |message|
      message << " with properties #{@properties}" if @properties.present?
    end
  end
end
