require 'yaml'
require 'erb'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
module Lurker
  class Endpoint
    include Lurker::Utils

    PREFIX = 'prefix'.freeze
    ACTION = 'action'.freeze
    CONTROLLER = 'controller'.freeze
    EXTENSIONS = 'extensions'.freeze
    PATH_PARAMS = 'path_params'.freeze
    QUERY_PARAMS = 'query_params'.freeze
    DEPRECATED = 'deprecated'.freeze
    DESCRIPTION = 'description'.freeze
    RESPONSE_CODES = 'responseCodes'.freeze
    REQUEST_PARAMETERS = 'requestParameters'.freeze
    RESPONSE_PARAMETERS = 'responseParameters'.freeze
    DESCRPTIONS = {
      'index' => 'listing',
      'show' => '',
      'edit' => 'editing',
      'create' => 'creation',
      'update' => 'updating',
      'destroy' => 'descruction'
    }.freeze

    attr_reader :schema, :service, :endpoint_path, :extensions

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
      finalize_schema!

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
      @schema[DEPRECATED]
    end

    def prefix
      @schema[PREFIX]
    end

    def description
      @schema[DESCRIPTION]
    end

    def url_params
      (@schema[EXTENSIONS][PATH_PARAMS] || {}).reject { |k, _| %w(action controller format).include? k }
    end

    def query_params
      (@schema[EXTENSIONS][QUERY_PARAMS] || {})
    end

    def request_parameters
      @schema[REQUEST_PARAMETERS]
    end

    def response_parameters
      @schema[RESPONSE_PARAMETERS]
    end

    def response_codes
      @schema[RESPONSE_CODES]
    end

    def documentation
      @schema.documentation
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
        DESCRIPTION => '',
        PREFIX => '',
        REQUEST_PARAMETERS => {},
        RESPONSE_CODES => [],
        RESPONSE_PARAMETERS => {}
      }
      schemify(payload)
    end

    def schemify(payload)
      Lurker::Json::Parser.plain(uri: endpoint_path).parse(payload).tap do |schm|
        ext = Lurker::Json::Extensions.new(stringify_keys extensions)
        schm.merge!(EXTENSIONS => ext)
      end
    end

    def finalize_schema!
      path_params = schema[EXTENSIONS][PATH_PARAMS] || {}
      subject = path_params[CONTROLLER].to_s.split(/\//).last.to_s
      description = DESCRPTIONS[path_params[ACTION]]

      schema[DESCRIPTION] = "#{subject.singularize} #{description}".strip if schema[DESCRIPTION].blank?
      schema[PREFIX] = "#{subject} management" if schema[PREFIX].blank?
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
