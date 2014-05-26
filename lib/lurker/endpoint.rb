require 'yaml'
require 'erb'
require 'json-schema'

# Endpoints represent the schema for an API endpoint
# The #consume_* methods will raise exceptions if input differs from the schema
class Lurker::Endpoint

  attr_reader :schema, :service, :endpoint_path, :current_scaffold, :extensions
  attr_accessor :errors

  def initialize(endpoint_path, extensions={}, service=Lurker::Service.default_service)
    @endpoint_path = endpoint_path
    @extensions = extensions
    @service = service
    @errors = []
    @persisted = false
    @schema = File.exist?(endpoint_path) ? load_schema : build_schema
  end

  def persist!
    schema.ordered!.write_to(endpoint_path)
    @persisted = true
  end

  def indexed?
    prefix.present? && description.present?
  end

  def consume!(request_params, response_params, status_code, successful=true)
    consume_request(request_params, successful)
    consume_response(response_params, status_code, successful)
    raise_errors!
  end

  def consume_request(params, successful=true)
    if successful
      Lurker::SchemaModifier.merge!(request_parameters, params)
    end
  end

  def consume_response(params, status_code, successful=true)
    return validate_response(params, status_code, successful) if persisted?

    if successful
      Lurker::SchemaModifier.merge!(response_parameters, params)
    end

    if !status_code_exists?(status_code, successful)
      response_code = {
        "status" => status_code,
        "successful" => successful,
        "description" => ""
      }

      Lurker::SchemaModifier.append!(response_codes, response_code)
    end
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

  def request_parameters
    @schema["requestParameters"] ||= {}
  end

  def response_parameters
    @schema["responseParameters"] ||= {}
  end

  def response_codes
    @schema["responseCodes"] ||= []
  end

  protected

  def persisted?
    !!@persisted
  end

  def load_schema
    @persisted = true

    Lurker::Schema.new(
      load_file(endpoint_path),
      extensions
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
      extensions
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

  def validate(expected_params, given_params, prefix=nil)
    schema = set_additional_properties_false_on(expected_params.dup)
    schema['id'] = "file://#{endpoint_path}"
    unless (_errors = Lurker::Validator.new(schema, given_params, record_errors: true).validate).empty?
      self.errors << prefix
      _errors.each { |e| self.errors << "- #{e}" }
      return false
    end
    true
  end

  def validate_response(params, status_code, successful)
    if !status_code_exists?(status_code, successful)
      raise Lurker::UndocumentedResponseCode,
        'Undocumented response: %s, successful: %s' % [
          status_code, successful
        ]
    elsif successful
      validate(response_parameters, params, 'Response')
    else
      true
    end
  end

  def status_code_exists?(status_code, successful)
    !!response_codes.detect do |code|
      code["successful"] == successful &&
        (code["status"] == status_code ||    # 200
         code["status"].to_i == status_code) # "200 OK"
    end
  end

  def raise_errors!
    unless errors.empty?
      raise Lurker::ValidationError.new(word_wrap((
        # ['Schema', "- #{endpoint_path}"] +
        errors
        # + ['Diff', current_scaffold.schema.diff(schema)]
      ).join("\n")))
    end
  end

  def word_wrap(text)
    text.gsub(/\s+in schema/m, "\n  in schema")
  end

  # default additionalProperties on objects to false
  # create a copy, so we don't mutate the input
  def set_additional_properties_false_on(value)
    if value.kind_of? Hash
      copy = value.dup
      if value["type"] == "object" || value.has_key?("properties")
        copy["additionalProperties"] ||= false
      end
      value.each do |key, hash_val|
        unless key == "additionalProperties"
          copy[key] = set_additional_properties_false_on(hash_val)
        end
      end
      copy
    elsif value.kind_of? Array
      copy = value.map do |arr_val|
        set_additional_properties_false_on(arr_val)
      end
    else
      value
    end
  end
end
