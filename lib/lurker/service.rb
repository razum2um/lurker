require 'yaml'

# Services represent a group of Lurker API endpoints in a directory
class Lurker::Service
  attr_reader :service_dir, :schema
  attr_writer :documentation
  attr_accessor :opened_endpoints
  SUFFIX = '.service.yml'
  DEFAULT_SCHEMA = {
      name: '',
      basePath: '',
      description: '',
      domains: {},
      consumes: %w(application/x-www-form-urlencode application/json),
      produces: %w(application/json)
  }

  def self.default_service
    new(Lurker.service_path)
  end

  def initialize(service_dir, service_name = nil)
    @opened_endpoints = []
    @service_dir = File.expand_path(service_dir)
    @service_filename = service_name
    @schema = if persisted? && (schema = YAML.load_file(service_path)).is_a?(Hash)
      Lurker::Json::Schema.new(schema, uri: service_path)
    else
      Lurker::Json::Schema.new(DEFAULT_SCHEMA.merge(name: service_filename), uri: service_path)
    end
  end

  def persisted?
    File.exist?(service_path)
  end

  def service_path
    @service_path ||= "#{service_dir}/#{service_filename}#{SUFFIX}"
  end

  def service_filename
    @service_filename ||= Pathname.new(Dir["#{service_dir}/*#{SUFFIX}"].first.to_s).basename.to_s.gsub(SUFFIX, '').presence || 'application'
  end

  def persist!
    Lurker::Json::Writer.write(schema, service_path) unless File.exist?(service_path)
    @opened_endpoints.each { |ep| ep.persist! if ep.respond_to?(:persist!) }
  end

  def verify!(verb, path, request_params,
              extensions, response_status, response_params, successful=true)
    endpoint = open(verb, path, extensions)
    endpoint.consume!(request_params, response_params, response_status, successful)
  end

  # Returns an Endpoint described by (verb, path)
  # In scaffold_mode, it will return an EndpointScaffold an of existing file
  #   or create an empty EndpointScaffold
  def open(verb, path, path_params={})
    endpoint_path = path_for(verb, path)
    endpoint_fname = Dir["#{endpoint_path}*"].first

    Lurker::Endpoint.new(endpoint_fname || endpoint_path, path_params, self).tap do |ep|
      @opened_endpoints << ep
    end
  end

  def endpoint_paths
    Dir["#{service_dir}/**/*.json"] + Dir["#{service_dir}/**/*.json.yml"] + Dir["#{service_dir}/**/*.json.yml.erb"]
  end

  def endpoints
    @endpoints ||= endpoint_paths.map do |path|
      Lurker::Endpoint.new(path, {}, self)
    end.select(&:indexed?).compact
  end

  def path_for(verb, path)
    flat_path   = fix_endpoint_path(File.join(@service_dir, "#{path}-#{verb.to_s.upcase}.json.yml"))
    nested_path = fix_endpoint_path(File.join(@service_dir, "#{path}/#{verb.to_s.upcase}.json.yml"))

    if File.exist?(flat_path)
      flat_path
    elsif File.exist?(nested_path)
      nested_path
    else # neither exists, default to flat_path
      flat_path
    end
  end

  def fix_endpoint_path(path)
    path.gsub(/:/, '__')
  end

  def name
    schema['name']
  end

  def base_path
    base_path = @schema['basePath']
    if base_path && !base_path.end_with?('/')
      base_path + '/'
    else
      base_path
    end
  end

  def description
    schema['description']
  end

  def discussion
    schema['discussion']
  end

  def domains
    schema['domains']
  end

  def request_media_types
    schema['consumes']
  end

  def response_media_types
    schema['produces']
  end

  def documentation
    @documentation ||= schema.documentation
  end
end
