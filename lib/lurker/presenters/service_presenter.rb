# An BasePresenter for Lurker::Service
class Lurker::ServicePresenter < Lurker::BasePresenter
  attr_reader :service

  extend Forwardable

  def_delegators :service, :name, :service_dir, :meta_service


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

  def to_markdown
    render_erb('service.md.erb')
  end

  def title
    "Lurker | #{name}"
  end

  def name_as_link(options = {})
    path = service.meta_service ? index_path(slug_name) : index_path
    '<a href="%s">%s %s</a>' % [ path, options[:prefix], service.name ]
  end

  def slug_name
    service.name.downcase.gsub(/[ \/]/, '_')
  end

  def url(extension = ".html")
    '%s-%s%s' % [ @endpoint.path, @endpoint.verb, extension ]
  end

  def endpoints
    if !@endpoints
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
      hash = Hash.new { |h,k| h[k] = Array.new }
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

  def description(options = {:render => true})
    options[:render] ? render_markdown(service.description) : service.description
  end

  def discussion(options = {:render => true})
    options[:render] ? render_markdown(service.discussion) : service.discussion
  end

  def relative_meta_service_path(file_name = nil)
    service_path = service_dir.gsub(meta_service.meta_service_dir, "")
    service_path = service_path.count("/").times.map { "../" }.join
    if file_name
      service_path = File.join(service_path, file_name)
    end
    service_path
  end

end
