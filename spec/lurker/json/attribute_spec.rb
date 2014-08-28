require 'spec_helper'

describe Lurker::Json::Attribute do
  let(:klass) { described_class }

  describe '#parse_schema' do
    context 'when schema is boolean attribute' do
      let(:attribute) do
        klass.new(
          'description' => '',
          'type' => 'boolean',
          'example' => false
        )
      end
      let(:expected) do
        {
          'description' => '',
          'type' => 'boolean',
          'example' => false
        }
      end

      it { expect(attribute.to_hash).to eq expected }
    end

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
