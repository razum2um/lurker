require 'yaml'
require 'erb'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
module Lurker
  class Endpoint
    include Lurker::Utils

    attr_reader :schema, :service, :endpoint_path, :extensions
    # attr_accessor :errors

    def initialize(endpoint_path, extensions = {}, service = Lurker::Service.default_service)
      @endpoint_path = endpoint_path
      @extensions = extensions
      @service = service
      @persisted = false
      @schema = File.exist?(endpoint_path) ? load_schema : build_schema
      @request_errors = []
      @response_errors = []
    end

    def persist!
      Lurker::Json::Orderer.reorder(schema) unless persisted?
      Lurker::Json::Writter.write(schema, endpoint_path)

      @persisted = true
    end

    def indexed?
      prefix.present? && description.present?
    end

    def consume!(request_params, response_params, status_code, successful = true)
      consume_request(request_params, successful)
      consume_response(response_params, status_code, successful)

      raise_errors!
    end

    def consume_request(params, successful = true)
      parameters = stringify_keys(params)

      if persisted?
        @request_errors = request_parameters.validate(parameters)
        @request_errors.unshift('Request') unless @request_errors.empty?
      end

      request_parameters.merge!(parameters) if successful
    end

    def consume_response(params, status_code, successful = true)
      parameters = stringify_keys(params)

      if persisted?
        response_codes.validate!(status_code, successful)

        @response_errors = response_parameters.validate(parameters)
        @response_errors.unshift('Response') unless @response_errors.empty?

        return
      end

      response_parameters.merge!(parameters) if successful
      response_codes.merge!(status_code, successful)
    end

    def verb
      @verb ||= endpoint_path.match(/([A-Z]*)\.json(\.yml)?(\.erb)?$/)[1]
    end

    def path
      @path ||= endpoint_path.
                  gsub(service.service_dir, '').
                  match(/\/?(.*)[-\/][A-Z]+\.json(\.yml)?(\.erb)?$/)[1]
    end

    # properties

    def deprecated?
      @schema['deprecated']
    end

    def prefix
      @schema['prefix']
    end

    def description
      @schema['description']
    end

    # FIXME
    def url_params
      (@schema['extensions']['path_params'] || {}).reject { |k, _| %w(action controller format).include? k }
    end

    # FIXME
    def query_params
      (@schema['extensions']['query_params'] || {})
    end

    def request_parameters
      @schema['requestParameters']
    end

    def response_parameters
      @schema['responseParameters']
    end

    def response_codes
      @schema['responseCodes']
    end

    protected

    def persisted?
      !!@persisted
    end

    def load_schema
      @persisted = true

      reader = Lurker::Json::Reader.new(endpoint_path)
      schemify(reader.payload)
    end

    def build_schema
      @persisted = false

      payload = {
        'description' => '',
        'prefix' => '',
        'requestParameters' => {},
        'responseCodes' => [],
        'responseParameters' => {}
      }
      schemify(payload)
    end

    def schemify(payload)
      Lurker::Json::Parser.plain(uri: endpoint_path).parse(payload).tap do |schm|
        ext = Lurker::Json::Extensions.new(stringify_keys extensions)
        schm.merge!('extensions' => ext)
      end
    end

    def raise_errors!
      return if @response_errors.empty?

      errors = (@request_errors | @response_errors) * "\n"
      exception = Lurker::ValidationError.new(word_wrap errors)
      if (example = Lurker::Spy.current.block).respond_to?(:metadata) && (metadata = example.metadata).respond_to?(:location, true)
        exception.set_backtrace [metadata.send(:location)]
      end

      raise exception
    end

    def word_wrap(text)
      # strip .json# | .json.yml# | .json.yml.erb#
      text = text.reverse
      text.gsub!(/(\n|^)#bre\./, "\nbre.")
      text.gsub!(/(\n|^)#lmy\./, "\nlmy.")
      text.gsub!(/(\n|^)#nosj\./, "\nnosj.")
      text.strip!
      text = text.reverse

      text.gsub!(/\s+in schema/m, "\n  in schema")
      if defined?(Rails)
        text.gsub!(/file:\/\/#{Rails.root}\//m, "")
      end
      text
    end
  end
end
