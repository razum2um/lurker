require 'thor'
require 'execjs'
require 'digest/sha1'
require 'lurker/service'
require 'active_support/inflector'

module Lurker
  # A Thor::Error to be thrown when an lurker directory is not found
  class NotFound < Thor::Error; end

  # A Thor definition for an lurker to HTML conversion operation
  class Cli < Thor
    include Thor::Actions

    attr_accessor :origin_path, :content

    def self.source_root
      File.expand_path("../templates", __FILE__)
    end

    def self.precompiled_static_root
      File.expand_path("../templates/public", __FILE__)
    end

    desc "convert [LURKER_PATH]", "Convert lurker to HTML"
    method_option :rails, :type => :boolean, :desc => "Includes Rails environment"
    method_option :exclude, :aliases => "-e", :desc => "Select endpoints by given regexp, if NOT matching prefix"
    method_option :select, :aliases => "-s", :desc => "Select endpoints by given regexp, matching prefix"
    method_option :output, :aliases => "-o", :desc => "Output path", :default => "public"
    method_option :url_base_path, :aliases => "-u", :desc => "URL base path", :default => Lurker::DEFAULT_URL_BASE
    method_option :format, :aliases => "-f", :desc => "Format in html or pdf, defaults to html", :default => "html"
    method_option :templates, :aliases => "-t", :desc => "Template overrides path"
    method_option :content, :aliases => "-c", :desc => "Content to be rendered into html-docs main page"
    def convert(lurker_path=Lurker::DEFAULT_SERVICE_PATH)
      say_status nil, "Converting lurker to #{options[:format]}"

      self.content = get_content(options[:content])
      self.origin_path = File.expand_path(lurker_path)
      raise Lurker::NotFound.new(origin_path) unless has_valid_origin?
      say_status :using, lurker_path

      FileUtils.mkdir_p(output_path)
      say_status :inside, output_path

      if options[:rails]
        require "#{Dir.pwd}/config/environment"
      end

      if options[:format] == 'pdf'
        convert_to_pdf
      else
        convert_to_html
      end
    end

    no_tasks do
      def convert_to_pdf
        Lurker.safe_require('pdfkit')
        css = File.expand_path('application.css', self.class.precompiled_static_root)
        inside(output_path) do
          service_presenters.each do |service_presenter|
            html = "<html><body>"
            service_presenter.endpoints.each do |endpoint_prefix_group|
              endpoint_prefix_group.each do |endpoint_presenter|
                html << endpoint_presenter.to_html(layout: false)
              end
            end
            html << "</body></html>"
            kit = PDFKit.new(html, :page_size => 'Letter')
            kit.stylesheets << css
            url_name = ActiveSupport::Inflector.parameterize(service_presenter.name, '_')
            create_file("#{url_name}.pdf", kit.to_pdf, force: true)
          end
        end
      end

      def convert_to_html
        inside(output_path) do
          # js, css, fonts
          static = []
          Dir["#{self.class.precompiled_static_root}/*"].each do |fname|
            if match = fname.match(/application\.(js|css)$/)
              sha1 = Digest::SHA1.hexdigest(open(fname).read)
              html_options.merge! match[1] => sha1
              static << (new_name = "application-#{sha1}.#{match[1]}")
              FileUtils.cp_r fname, new_name
              spawn "cat #{new_name} | gzip -9 > #{new_name}.gz"
            else
              FileUtils.cp_r fname, Pathname.new(fname).basename.to_s
            end
          end

          service_presenters.each do |service_presenter|
            create_file("index.html", service_presenter.to_html, force: true)

            service_presenter.endpoints.each do |endpoint_prefix_group|
              endpoint_prefix_group.each do |endpoint_presenter|
                create_file(endpoint_presenter.relative_path, endpoint_presenter.to_html, force: true)
              end
            end
          end

          # cleanup
          Dir.glob("*.js").each do |fname|
            FileUtils.rm fname unless static.include? fname
          end
          Dir.glob("*.css").each do |fname|
            FileUtils.rm fname unless static.include? fname
          end
          Dir.glob("*.gz").each do |fname|
            FileUtils.rm fname unless static.include? fname.sub(/\.gz/, '')
          end
        end
      end

      def output_path
        "#{output_prefix}/#{url_base_path}"
      end

      def output_prefix
        if explicit = options[:output]
          explicit.sub(/\/?#{url_base_path}\/?$/, '')
        elsif File.exists? "public"
          "public"
        else
          raise "Please, run it from `Rails.root` or pass `-o` option"
        end
      end

      def template_path
        @template_path ||=
          if options[:templates]
            File.expand_path(options[:templates])
          else
            File.expand_path("../templates", origin_path)
          end
      end

      def has_valid_origin?
        origin.directory?
      end

      def service_presenters
        @service_presenters ||= services.map do |service|
          Lurker::ServicePresenter.new(service, html_options, &filtering_block)
        end
      end

      def filtering_block
        if options['select'].present?
          select = /#{options['select']}/
        end

        if options['exclude'].present?
          exclude = /#{options['exclude']}/
        end

        ->(endpoint_presenter) {
          prefix = endpoint_presenter.endpoint.schema['prefix']
          if prefix.present?
            return if select.present? && !prefix.match(select)
            return if exclude.present? && prefix.match(exclude)
          end
          endpoint_presenter
        }
      end

      def html_options
        @html_options ||= {
          :static_html => true,
          :url_base_path => url_base_path.prepend('/'),
          :template_directory => template_path,
          :html_directory => output_path,
          :content => self.content,
          :footer => (`git rev-parse --short HEAD`.to_s.strip rescue ""),
          :lurker => gem_info
        }
      end
    end

    private

    def url_base_path
      options[:url_base_path].presence.try(:strip).try(:sub, /^\/+/, '') || Lurker::DEFAULT_URL_BASE
    end

    def gem_info
      spec = if Bundler.respond_to? :locked_gems
        Bundler.locked_gems.specs.select { |s| s.name == 'lurker' } .first # 1.6
      else
        Bundler.definition.sources.detect { |s| s.specs.map(&:name).include?('lurker') } # 1.3
      end

      if spec.source.respond_to? :revision, true # bundler 1.3 private
        "#{spec.name} (#{spec.source.send(:revision)})"
      else
        spec.to_s
      end
    rescue => e
      puts e
      "lurker (unknown)"
    end

    def get_content(content_fname)
      return unless content_fname
      content_fname = File.expand_path(content_fname)
      if content_fname.ends_with? 'md'
        Lurker.safe_require('kramdown')
        Kramdown::Document.new(open(content_fname).read).to_html
      else
        ''
      end
    end

    def services
      @services ||= [Lurker::Service.new(origin_path)]
    end

    def origin
      Pathname.new(origin_path)
    end
  end
end
