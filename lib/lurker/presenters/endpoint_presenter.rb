# BasePresenter for an Endpoint
class Lurker::EndpointPresenter < Lurker::BasePresenter
  attr_accessor :service_presenter, :endpoint, :endpoint_presenter

  extend Forwardable
  def_delegators :endpoint, :description

  def initialize(endpoint, options = {})
    super(options)
    @endpoint = endpoint
    @endpoint_presenter = self
    @service_presenter = Lurker::ServicePresenter.new(endpoint.service)
  end

  def to_html(options={})
    @service_presenter = service_presenter
    @endpoint_presenter = self
    @url_params = endpoint.url_params
    @post_params = example_request.json
    render('show', options)
  end

  def relative_path(extension = ".html")
    '%s%s-%s%s' % [ options[:prefix], endpoint.path, endpoint.verb, extension ]
  end

  def url(extension = ".html")
    Pathname.new(html_directory).join(relative_path(extension)).to_s
  end

  def title
    '%s %s - %s' % [ endpoint.verb, endpoint.path, endpoint.service.name ]
  end

  def prefix
    endpoint.prefix || endpoint.path.split("/").first
  end

  def zws_ify(str)
    # zero-width-space, makes long lines friendlier for breaking
    #str.gsub(/\//, '&#8203;/') if str
    str
  end

  def root_path
    URI.parse("file://#{endpoint.endpoint_path}")
  end

  def request_parameters
    Lurker::SchemaPresenter.new(endpoint.request_parameters,
      options.merge(request: true, root_path: root_path)
    )
  end

  def response_parameters
    return if endpoint.response_parameters.empty?
    Lurker::SchemaPresenter.new(endpoint.response_parameters, options.merge(root_path: root_path))
  end

  def response_codes
    @response_codes ||= endpoint.response_codes.map do |response_code|
      Lurker::ResponseCodePresenter.new(response_code, options)
    end
  end

  def successful_response_codes
    response_codes.select(&:successful?)
  end

  def failure_response_codes
    response_codes.reject(&:successful?)
  end

  def example_request
    return if endpoint.request_parameters.empty?
    Lurker::JsonPresenter.new(
      example_from_schema(endpoint.request_parameters, endpoint.schema)
        .reject { |k,_| endpoint.url_params.keys.include? k }
    )
  end

  def example_response
    return @example_response if @example_response
    return if endpoint.response_parameters.empty?
    response = example_from_schema(endpoint.response_parameters, endpoint.schema)
    @example_response = response.to_json
    @highlighted = false
    Lurker.safe_require("execjs", "to get samples highlighted") do
      jsfile = File.expand_path('javascripts/highlight.pack.js', Lurker::Cli.source_root)
      source = open(jsfile).read
      context = ExecJS.compile(source)
      @example_response = context.exec("return hljs.highlightAuto(JSON.stringify(#{@example_response}, null, 2)).value")
      @highlighted = true
    end
    unless @highlighted
      Lurker.safe_require("coderay", "to get samples highlighted") do
        #::CodeRay.scan(response.to_json, :jjson).html(wrap: nil, css: :class) # forked compatible version
        @example_response = ::CodeRay.scan(@example_response, :json).html(wrap: nil, css: :class)
        @highlighted = true
      end
    end
    @example_response
  end

  def deprecated?
    @endpoint.deprecated?
  end

  def base_path
    zws_ify(@endpoint.service.base_path)
  end

  # for live form WITH values
  # TODO: remove in favor of named_path
  def path
    return @path if @path
    unless (@path = @endpoint.schema.extensions.try(:[], 'path_info')).present?
      @path = @endpoint.path.gsub(/__/, ':')
      @path = @path.gsub(/-#{@end}/) if @endpoint.schema.extensions.try(:[], 'suffix').present?
    end
    @path = '/' + @path.split('/').select(&:present?).join('/')
    @path
  end

  # for live form WITH :placeholders
  def named_path
    return @named_path if @named_path
    @named_path = base_path.sub(/\/?$/, '/') + endpoint.path.gsub(/__/, ':')
    if (suffix = endpoint.schema.extensions.try(:[], 'suffix')).present?
      @named_path = @named_path.gsub(/-#{suffix}/, '')
    end
    @named_path
  end

  def verb
    endpoint.verb
  end

  def form_verb
    if endpoint.verb == 'GET'
      'GET'
    else
      'POST'
    end
  end

  def verb_colorname
    case endpoint.verb
      when 'GET' then 'success'
      when 'POST' then 'primary'
      when 'PUT' then 'warning'
      when 'PATCH' then 'warning'
      when 'DELETE' then 'danger'
    else
      'default'
    end
  end

  ATOMIC_TYPES = %w(string integer number boolean null)

  def example_from_schema(schema, parent=nil)
    if schema.nil?
      return nil
    end

    type = Array(schema["type"])

    if type.any? { |t| ATOMIC_TYPES.include?(t) }
      schema["example"] || schema["default"] || example_from_atom(schema, parent)
    elsif type.include?("object") || schema["properties"]
      example_from_object(schema, parent)
    elsif type.include?("array") || schema["items"]
      example_from_array(schema, parent)
    elsif (ref_path = schema['$ref'])
      root_path = parent.respond_to?(:abs_path) ? parent.abs_path : send(:root_path)
      ref_schema = Lurker::RefObject.new(ref_path, root_path)
      example_from_object(ref_schema.schema, ref_schema)
    else
      {}
    end
  end

  def example_from_atom(schema, parent=nil)
    type = Array(schema["type"])
    hash = schema.hash

    if type.include?("boolean")
      [true, false][hash % 2]
    elsif type.include?("integer")
      hash % 1000
    elsif type.include?("number")
      Math.sqrt(hash % 1000).round 2
    elsif type.include?("string")
      ""
    else
      nil
    end
  end

  def example_from_object(object, parent=nil)
    example = {}
    if object["properties"]
      object["properties"].each do |key, value|
        example[key] = example_from_schema(value, parent)
      end
    end
    example
  end

  def example_from_array(array, parent=nil)
    if array["items"].kind_of? Array
      example = []
      array["items"].each do |item|
        example << example_from_schema(item, parent)
      end
      example
    elsif (array["items"] || {})["type"].kind_of? Array
      example = []
      array["items"]["type"].each do |item|
        example << example_from_schema(item, parent)
      end
      example
    else
      [ example_from_schema(array["items"], parent) ]
    end
  end
end
