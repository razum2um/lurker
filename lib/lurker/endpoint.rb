require 'yaml'
require 'erb'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
module Lurker
  class Endpoint
    include Lurker::Utils

    attr_reader :schema, :service, :endpoint_path, :extensions
    attr_reader :request_parameters, :response_parameters, :response_codes
    attr_accessor :errors

    def initialize(endpoint_path, extensions = {}, service = Lurker::Service.default_service)
      @endpoint_path = endpoint_path
      @extensions = extensions
      @service = service
      @errors = []
      @persisted = false
      @schema = File.exist?(endpoint_path) ? load_schema : build_schema

      initialize_schema_properties
    end

    def persist!
      schema.ordered! unless persisted?
      schema.write_to(endpoint_path)

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
      request_parameters.validate(params) if persisted?
      request_parameters.add(params) if successful
    end

    def consume_response(params, status_code, successful = true)
      if persisted?
        response_codes.validate!(status_code, successful)
        response_parameters.validate(params) if successful

        return
      end

      response_parameters.add(params) if successful
      response_codes.add(status_code, successful) unless response_codes.exists?(
        status_code, successful)
    end

    def verb
      @verb ||= endpoint_path.match(/([A-Z]*)\.json(\.yml)?(\.erb)?$/)[1]
    end

    def path
      @path ||= endpoint_path.
                  gsub(service.service_dir, "").
                  match(/\/?(.*)[-\/][A-Z]+\.json(\.yml)?(\.erb)?$/)[1]
    end

    # properties

    def deprecated?
      @schema["deprecated"]
    end

    def prefix
      @schema["prefix"]
    end

    def description
      @schema["description"]
    end

    def url_params
      (schema.extensions['path_params'] || {}).reject { |k, _| ['action', 'controller', 'format'].include? k }
    end

    def query_params
      (schema.extensions['query_params'] || {})
    end

    protected

    def initialize_schema_properties
      @response_codes = ResponseCodes.new(schema)

      @response_parameters = HttpParameters.new(schema,
        schema_key: 'responseParameters', schema_id: endpoint_path, human_name: 'Response')

      @request_parameters = HttpParameters.new(schema,
        schema_key: 'requestParameters', schema_id: endpoint_path, human_name: 'Request')
    end

    def persisted?
      !!@persisted
    end

    def load_schema
      @persisted = true

      Lurker::Schema.new(
        load_file(endpoint_path),
        stringify_keys(extensions)
      )
    end

    def build_schema
      @persisted = false

      Lurker::Schema.new(
        {
          "prefix" => "",
          "description" => "",
          "responseCodes" => []
        },
        stringify_keys(extensions)
      )
    end

    def load_file(fname)
      if fname.match(/\.erb$/)
        context = Lurker::ErbSchemaContext.new
        erb = ERB.new(IO.read(fname)).result(context.get_binding)
        YAML.load(erb)
      else
        YAML.load_file(fname)
      end
    end

    def raise_errors!
      return if response_parameters.errors.empty?

      errors = (request_parameters.errors | response_parameters.errors) * "\n"
      raise Lurker::ValidationError.new(word_wrap errors)
    end

    def word_wrap(text)
      text.gsub(/\s+in schema/m, "\n  in schema")
    end
  end
end
