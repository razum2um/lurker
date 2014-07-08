require 'spec_helper'

describe Lurker::Json::Schema do
  let(:klass) { described_class }

  describe 'Merge request/response parameters' do
    let(:schema) { klass.new({'responseParameters' => {}}) }

    context 'when request parameters is an object' do
      let(:parameters) do
        {
          'id' => 1,
          'name' => 'Bob',
          'repos' => [{'id' => 1, 'name' => 'gem-gon'}]
        }
      end
      let(:expected) do
        {
          'description' => '',
          'type' => 'object',
          'additionalProperties' => false,
          'required' => [],
          'properties' => {
            'id' => {
              'description' => '',
              'type' => 'integer',
              'example' => 1
            },
            'name' => {
              'description' => '',
              'type' => 'string',
              'example' => 'Bob'
            },
            'repos' => {
              'type' => 'array',
              'items' => {
                'description' => '',
                'type' => 'object',
                'additionalProperties' => false,
                'required' => [],
                'properties' => {
                  'id' => {
                    'description' => '',
                    'type' => 'integer',
                    'example' => 1
                  },
                  'name' => {
                    'description' => '',
                    'type' => 'string',
                    'example' => 'gem-gon'
                  }
                }
              }
            }
          }
        }
      end
      before { schema['responseParameters'].merge! parameters }

      it { expect(schema['responseParameters'].to_hash).to eq expected }
    end

    context 'when request parameters is an array of objects' do
      let(:parameters) { [{'id' => 1, 'name' => 'Bob'}, {'id' => 2, 'name' => 'Tom'}] }
      let(:expected) do
        {
          'type' => 'array',
          'items' => {
            'description' => '',
            'type' => 'object',
            'additionalProperties' => false,
            'required' => [],
            'properties' => {
              'id' => {
                'description' => '',
                'type' => 'integer',
                'example' => 1
              },
              'name' => {
                'description' => '',
                'type' => 'string',
                'example' => 'Bob'
              }
            }
          }
        }
      end
      before { schema['responseParameters'].merge! parameters }

      it { expect(schema['responseParameters'].to_hash).to eq expected }
    end

    context 'when request parameters is an object with array of strings' do
      let(:parameters) { {'errors' => {'name' => ['Couldn`t be blank']}} }
      let(:expected) do
        {
          'description' => '',
          'type' => 'object',
          'additionalProperties' => false,
          'required' => [],
          'properties' => {
            'errors' => {
              'description' => '',
              'type' => 'object',
              'additionalProperties' => false,
              'required' => [],
              'properties' => {
                'name' => {
                  'type' => 'array',
                  'items' => {
                    'description' => '',
                    'type' => 'string',
                    'example' => 'Couldn`t be blank'
                  }
                }
              }
            }
          }
        }
      end
      before { schema['responseParameters'].merge! parameters }

      it { expect(schema['responseParameters'].to_hash).to eq expected }
    end
  end
end
