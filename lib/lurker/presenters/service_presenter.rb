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

  # TODO move to controller
  def to_html(&block)
    @service_presenter = self
    render('index')
  end

  def title
    "Lurker | #{name}"
  end

  def domains
    return service.domains if service.domains.present?
    { '/' => 'Local' }
  end

  def default_domain
    return service.domains.to_a[0][1] if service.domains.present?
    '/'
  end

  def name_as_link(options = {})
    path = index_path
    '<a href="%s">%s %s</a>' % [path, options[:prefix], service.name]
  end

  def slug_name
    service.name.downcase.gsub(/[ \/]/, '_')
  end

  def url(extension = ".html")
    '%s-%s%s' % [@endpoint.path, @endpoint.verb, extension]
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
end
