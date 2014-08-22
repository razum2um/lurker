require 'spec_helper'

describe Lurker::Json::Object do
  let(:klass) { described_class }

  describe '#parse_schema' do
    context 'when schema is empty hash' do
      let(:object) { klass.new({}) }
      let(:expected) do
        {
          'description' => '',
          'type' => 'object',
          'additionalProperties' => false,
          'required' => [],
          'properties' => {}
        }
      end

      it { expect(object.to_hash).to eq expected }
    end
  end

  describe '#merge!' do
    context 'when merge a hash with properties containing empty hash' do
      let(:object) { klass.new({}) }
      let(:expected) do
        {
          'description' => '',
          'type' => 'object',
          'additionalProperties' => false,
          'required' => [],
          'properties' => {
            'name' => {
              'description' => '',
              'type' => 'string',
              'example' => 'razum2um'
            },
            'repo' => {
              'description' => '',
              'type' => 'object',
              'additionalProperties' => false,
              'required' => [],
              'properties' => {}
            }
          }
        }
      end

      before { object.merge!('name' => 'razum2um', 'repo' => {}) }

      it { expect(object.to_hash).to eq expected }
    end
    context 'when merge a hash with keywords' do
      let(:object) { klass.new('name' => 'razum2um') }
      let(:expected) do
        {
          'description' => '',
          'type' => 'object',
          'additionalProperties' => false,
          'required' => [],
          'properties' => {
            'name' => {
              'description' => '',
              'type' => 'string',
              'example' => 'razum2um'
            },
            'achievement' => {
              'description' => '',
              'type' => 'object',
              'additionalProperties' => false,
              'required' => [],
              'properties' => {
                'type' => {
                  'description' => '',
                  'type' => 'string',
                  'example' => 'unlocked'
                }
              }
            }
          }
        }
      end

      before { object.merge!('achievement' => {'type' => 'unlocked'}) }

      it { expect(object.to_hash).to eq expected }
    end
  end
end
