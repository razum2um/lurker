require 'active_support/inflector'

# An BasePresenter for Lurker::Service
class Lurker::ServicePresenter < Lurker::BasePresenter
  attr_reader :service

  extend Forwardable
  def_delegators :service, :description, :discussion, :name, :service_dir

  def initialize(service, options = {}, &block)
    super(options)
    @service = service
    @filtering_block = block
  end

  def to_html(options={}, &block)
    controller = Lurker::RenderingController.new
    controller.service_presenter = self
    controller.render_to_string 'index', options
  end

  def to_print(options = {})
    controller = Lurker::RenderingController.new
    controller.service_presenter = self
    controller.render_to_string 'all', { layout: 'print' }.merge(options)
  end

  def documentation
    markup @service.documentation
  end

  def title
    "#{name}"
  end

  def domains
    return service_domains if service_domains.present?
    { '/' => 'Local' }
  end

  def default_domain
    return service_domains.to_a[0][1] if service_domains.present?
    '/'
  end

  def request_media_types
    return service.request_media_types if service.request_media_types.present?
    ['application/x-www-form-urlencoded']
  end

  def default_request_media_type
    request_media_types[0]
  end

  def name_as_link(options = {})
    path = index_path
    '<a href="%s">%s %s</a>' % [path, options[:prefix], service.name]
  end

  def slug_name
    @slug_name ||= service.name.downcase.gsub(/[ \/]/, '_')
  end

  def url_name
    @url_name ||= ActiveSupport::Inflector.parameterize(name, '_')
  end

  def url(extension = ".html")
    '%s-%s%s' % [@endpoint.path, @endpoint.verb, extension]
  end

  def footer
    @footer ||= options[:footer].present? ? "Revision&nbsp;#{options[:footer]}".html_safe : ''
  end

  def lurker
    @lurker ||= options[:lurker] || ''
  end

  def endpoints
    unless @endpoints
      @endpoints = []
      prefix = nil

      service.endpoints.sort_by(&:endpoint_path).each do |endpoint|
        presenter = Lurker::EndpointPresenter.new(endpoint, options)
        presenter.service_presenter = self

        if @filtering_block
          presenter = @filtering_block.call(presenter)
          next if presenter.nil?
        end

        current_prefix = presenter.prefix

        @endpoints << [] if prefix != current_prefix
        @endpoints.last << presenter

        prefix = current_prefix
      end
    end

    @endpoints
  end

  def endpoints_by_prefix
    @endpoints_by_prefix ||= begin
      hash = Hash.new { |h, k| h[k] = Array.new }
      service.endpoints.sort_by(&:endpoint_path).each do |endpoint|
        presenter = Lurker::EndpointPresenter.new(endpoint, options)
        presenter.service_presenter = self

        if @filtering_block
          presenter = @filtering_block.call(presenter)
          next if presenter.nil?
        end

        hash[presenter.prefix] << presenter
      end
      hash
    end
  end

  private

  def service_domains
    service.domains.try(:to_hash) || {}
  end
end
