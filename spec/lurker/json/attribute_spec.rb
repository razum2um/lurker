require 'spec_helper'

describe Lurker::Json::Attribute do
  let(:klass) { described_class }

  describe '#parse_schema' do
    context 'when default attributes order are broken by user' do
      let(:attribute) do
        klass.new(
          'example' => 'razum2um',
          'description' => '',
          'type' => 'string'
        )
      end
      let(:expected) do
        {
          'example' => 'razum2um',
          'description' => '',
          'type' => 'string'
        }.to_json
      end

      it { expect(attribute.to_json).to eq expected }
    end
  end
end
