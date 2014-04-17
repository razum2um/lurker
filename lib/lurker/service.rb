require 'yaml'

# Services represent a group of Lurker API endpoints in a directory
class Lurker::Service
  attr_reader :service_dir, :schema
  attr_accessor :meta_service, :opened_endpoints
  SUFFIX = '.service.yml'

  def self.default_service
    new(Lurker.service_path)
  end

  def initialize(service_dir, service_name = nil)
    @name = service_name
    @opened_endpoints = []
    @service_dir = File.expand_path(service_dir)
    @schema = if persisted? && (schema = YAML.load_file(service_path)).is_a?(Hash)
      Lurker::Schema.new(schema)
    else
      Lurker::Schema.new({
        'name'        => name,
        'basePath'    => '',
        'description' => '',
        'domains'     => ['']
      })
    end
  end

  def persisted?
    File.exist?(service_path)
  end

  def service_path
    @service_path ||= "#{service_dir}/#{name}#{SUFFIX}"
  end

  def persist!
    schema.write_to(service_path) unless File.exists?(service_path)
    @opened_endpoints.each { |e| e.persist! if e.respond_to? :persist! }
  end

  def verify!(verb, path, extensions, request_params, response_params,
                   response_status, successful)
    endpoint = open(verb, path, extensions)
    endpoint.consume!(request_params, response_params, response_status, successful)
  end


  # Returns an Endpoint described by (verb, path)
  # In scaffold_mode, it will return an EndpointScaffold an of existing file
  #   or create an empty EndpointScaffold
  def open(verb, path, path_params={})
    endpoint_path = path_for(verb, path)
    endpoint_fname = Dir["#{endpoint_path}*"].first

    endpoint = if endpoint_fname.present?
      Lurker::Endpoint.new(endpoint_fname, path_params, self)
    else
      Lurker::EndpointScaffold.new(endpoint_path, path_params, self)
    end
    @opened_endpoints << endpoint
    endpoint
  end

  def endpoint_paths
    Dir["#{service_dir}/**/*.json"] + Dir["#{service_dir}/**/*.json.yml"] + Dir["#{service_dir}/**/*.json.yml.erb"]
  end

  def endpoints
    endpoint_paths.map do |path|
      Lurker::Endpoint.new(path, {}, self)
    end
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
    @name ||= (@schema.try(:[], 'name') ||
               Pathname.new(Dir["#{service_dir}/*#{SUFFIX}"].first.to_s).basename.to_s.gsub(SUFFIX, '').presence ||
               'application')
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
    @schema['description']
  end

  def discussion
    @schema['discussion']
  end
end
