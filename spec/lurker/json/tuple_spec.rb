require 'spec_helper'

describe Lurker::Json::Tuple do
  let(:klass) { Lurker::Json::Tuple::AnyOf }

  describe '#parse_schema' do
    context 'when schema is empty hash' do
      let(:tuple) { klass.new({}) }
      let(:expected) do
        {
          'anyOf' => [],
        }
      end

      it { expect(tuple.to_hash).to eq expected }
    end

    context 'when schema is array' do
      let(:tuple) do
        klass.new(['razum2um', 42])
      end

      let(:expected) do
        {
          'anyOf' => [
            {
              'type' => 'string',
              'description' => '',
              'example' => 'razum2um'
            },
            {
              'type' => 'integer',
              'description' => '',
              'example' => 42
            }
          ],
        }
      end

      it { expect(tuple.to_hash).to eq expected }
    end
  end

  describe '#merge!' do
    context 'when merge with empty tuple' do
      let(:tuple) { klass.new({}) }
      let(:expected) do
        {
          'anyOf' => [
            {
              'type' => 'string',
              'description' => '',
              'example' => 'razum2um'
            }
          ]
        }
      end

      before { tuple.merge!('razum2um') }

      it { expect(tuple.to_hash).to eq expected }
    end

    context 'when merge new scheme in filled tuple' do
      let(:tuple) { klass.new(['razum2um']) }
      let(:expected) do
        {
          'anyOf' => [
            {
              'type' => 'string',
              'description' => '',
              'example' => 'razum2um'
            },
            {
              'type' => 'integer',
              'description' => '',
              'example' => 42
            }
          ]
        }
      end

      before { tuple.merge!(42) }

      it { expect(tuple.to_hash).to eq expected }
    end

    context 'when merge existing scheme in filled tuple' do
      let(:tuple) { klass.new(['razum2um']) }
      let(:expected) do
        {
          'anyOf' => [
            {
              'type' => 'string',
              'description' => '',
              'example' => 'razum2um'
            }
          ]
        }
      end

      before { tuple.merge!('oni.strech') }

      it { expect(tuple.to_hash).to eq expected }
    end
  end
end

