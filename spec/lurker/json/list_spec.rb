require 'spec_helper'

describe Lurker::Json::List do
  let(:klass) { described_class }

  describe '#parse_schema' do
    context 'when schema is empty array' do
      let(:list) { klass.new([]) }
      let(:expected) do
        {
          'type' => 'array',
          'items' => []
        }
      end

      it { expect(list.to_hash).to eq expected }
    end

    context 'when schema is empty hash' do
      let(:list) { klass.new({}) }
      let(:expected) do
        {
          'type' => 'array',
          'items' => {}
        }
      end

      it { expect(list.to_hash).to eq expected }
    end

    context 'when default attributes order are broken by user' do
      let(:list) { klass.new('items' => {}, 'type' => 'array') }
      let(:expected) do
        {
          'items' => {},
          'type' => 'array'
        }.to_json
      end

      it { expect(list.to_json).to eq expected }
    end
  end

  describe '#merge!' do
    context 'when list is not specify concrete type' do
      let(:list) { klass.new([]) }

      context 'when merge an array' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'integer',
              'example' => 42
            }
          }
        end
        before { list.merge!([42]) }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge an array of different types' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'anyOf' => [
                {
                  'description' => '',
                  'type' => 'integer',
                  'example' => 42
                },
                {
                  'description' => '',
                  'type' => 'string',
                  'example' => 'razum2um'
                }
              ]
            }
          }
        end
        before { list.merge!([42, 'razum2um']) }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a fixnum' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'integer',
              'example' => 999
            }
          }
        end
        before { list.merge!(999) }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a string' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'string',
              'example' => 'razum2um'
            }
          }
        end
        before { list.merge!('razum2um') }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a hash' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'object',
              'additionalProperties' => false,
              'required' => [],
              'properties' => {
                'name' => {
                  'description' => '',
                  'type' => 'string',
                  'example' => 'razum2um'
                }
              }
            }
          }
        end
        before { list.merge!('name' => 'razum2um') }

        it { expect(list.to_hash).to eq expected }
      end
    end

    context 'when list is an array of attributes' do
      let(:list) { klass.new([1, 2, 3]) }

      context 'when merge an array' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'integer',
              'example' => 1
            }
          }
        end
        before { list.merge!([42]) }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a fixnum' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'description' => '',
              'type' => 'integer',
              'example' => 1
            }
          }
        end
        before { list.merge!(999) }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a string' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'anyOf' => [
                {
                  'description' => '',
                  'type' => 'integer',
                  'example' => 1
                },
                {
                  'description' => '',
                  'type' => 'string',
                  'example' => 'razum2um'
                }
              ]
            }
          }
        end
        before { list.merge!('razum2um') }

        it { expect(list.to_hash).to eq expected }
      end

      context 'when merge a hash' do
        let(:expected) do
          {
            'type' => 'array',
            'items' => {
              'anyOf' => [
                {
                  'description' => '',
                  'type' => 'integer',
                  'example' => 1
                },
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
                    }
                  }
                }
              ]
            }
          }
        end
        before { list.merge!('name' => 'razum2um') }

        it { expect(list.to_hash).to eq expected }
      end
    end
  end
end
