require 'spec_helper'

describe Lurker::Json::Object do
  let(:klass) { described_class }

  describe '#merge!' do
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
