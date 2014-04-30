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
    @schema = Lurker::Schema.new(
      load_file(@endpoint_path),
      stringify_keys(extensions)
    )
    @service = service
    @errors = []
    @current_scaffold = Lurker::EndpointScaffold.new(
      "#{endpoint_path}.new", extensions, service
    )
  end

  def persist!
    return unless ENV['LURKER_UPGRADE']
    schema.write_to(endpoint_path)
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
      unless validate(request_parameters, params, 'Request')
        current_scaffold.consume_request(params, successful)
      end
    end
  end

  def consume_response(params, status_code, successful=true)
    response_code = response_codes.find do |rc|
      rc["successful"] == successful && (
        rc["status"]      == status_code || # 200
        rc["status"].to_i == status_code    # "200 OK"
      )
    end


    if !response_code
      raise Lurker::UndocumentedResponseCode,
        'Undocumented response: %s, successful: %s' % [
          status_code, successful
        ]
    elsif successful
      unless validate(response_parameters, params, 'Response')
        current_scaffold.consume_response(params, status_code, successful)
      end
    else
      true
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
    (schema.extensions['path_params'] || {}).except('action', 'controller')
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
    unless (_errors = Lurker::Validator.new(schema, stringify_keys(given_params), record_errors: true).validate).empty?
      self.errors << prefix
      _errors.each { |e| self.errors << "- #{e}" }
      return false
    end
    true
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

  def stringify_keys(obj)
    case obj
    when Hash
      result = {}
      obj.each do |k, v|
        result[k.to_s] = stringify_keys(v)
      end
      result
    when Array then obj.map { |v| stringify_keys(v) }
    else obj
    end
  end
end
