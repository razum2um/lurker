require 'thor'
require 'execjs'
require 'digest/sha1'
require 'lurker'
require 'active_support/inflector'

module Lurker
  BUNDLED_TEMPLATES_PATH = Pathname.new('../templates').expand_path(__FILE__)
  BUNDLED_ASSETS_PATH = Pathname.new('../templates/public').expand_path(__FILE__)

  # A Thor::Error to be thrown when an lurker directory is not found
  class NotFound < Thor::Error; end

  # A Thor definition for an lurker to HTML conversion operation
  class Cli < Thor
    include Thor::Actions

    attr_accessor :content

    def self.templates_root
      options[:template].present? ? Pathname.new(options[:templates]).expand_path : Lurker::BUNDLED_TEMPLATES_PATH
    end

    def self.assets_root
      options[:assets].present? ? Pathname.new(options[:assets]).expand_path : Lurker::BUNDLED_ASSETS_PATH
    end

    source_root(templates_root)

    desc 'init_docs [LURKER_PATH]', 'Create documentation stubs for service and endpoints'

    def init_docs(lurker_path=Lurker::DEFAULT_SERVICE_PATH)
      say_status nil, 'Creating documentation stubs'

      setup_schema_root! lurker_path

      schemas = Lurker.service.endpoints.map(&:schema) << Lurker.service.schema
      schemas.each do |schema|
        rel_path = Pathname.new(schema.documentation_uri).relative_path_from(Pathname.getwd)
        template 'documentation.md.tt', schema.documentation_uri, skip: true, path: rel_path
      end
    end

    desc 'convert [LURKER_PATH]', 'Convert lurker to HTML'
    option :rails, type: :boolean, desc: 'Includes Rails environment'
    option :exclude, aliases: '-e', desc: 'Select endpoints by given regexp, if NOT matching prefix'
    option :select, aliases: '-s', desc: 'Select endpoints by given regexp, matching prefix'
    option :output, aliases: '-o', desc: 'Output path', default: 'public'
    option :url_base_path, aliases: '-u', desc: 'URL base path', default: Lurker::DEFAULT_URL_BASE
    option :templates, aliases: '-t', desc: 'Template overrides path'
    option :assets, aliases: '-a', desc: 'Assets overrides path'
    option :format, aliases: '-f', desc: 'Format in html or pdf, defaults to html', default: 'html'
    option :content, aliases: '-c', desc: 'Content to be rendered into html-docs main page'

    def convert(lurker_path=Lurker::DEFAULT_SERVICE_PATH)
      say_status nil, "Converting lurker to #{options[:format]}"

      setup_schema_root! lurker_path
      require "#{Dir.pwd}/config/environment" if options[:rails]

      # for backward compatibility
      if options[:content]
        Lurker.service.documentation = open(File.expand_path(options[:content])).read
      end

      setup_rendering_engine!

      inside(output_path) do
        say_status :inside, output_path
        prepare_assets!
        if options[:format] == 'pdf'
          convert_to_pdf
        else
          convert_to_html
        end
        cleanup_assets!
      end
    end

    no_tasks do
      def convert_to_pdf
        Lurker.safe_require('pdfkit')
        print_html = service_presenter.to_print
        create_file "#{service_presenter.url_name}_print.html", print_html, force: true

        kit = PDFKit.new(print_html)
        kit.stylesheets << assets['application.css']
        create_file "#{service_presenter.url_name}.pdf", kit.to_pdf, force: true
      end

      def convert_to_html
        create_file 'index.html', service_presenter.to_html, force: true

        service_presenter.endpoints.each do |endpoint_prefix_group|
          endpoint_prefix_group.each do |endpoint_presenter|
            create_file(endpoint_presenter.relative_path, endpoint_presenter.to_html, force: true)
          end
        end
      end

      def setup_schema_root!(path)
        Lurker.service_path = File.expand_path(path)
        raise Lurker::NotFound.new(Lurker.service_path) unless Lurker.valid_service_path?
        say_status :using, path
      end

      def setup_rendering_engine!
        I18n.config.enforce_available_locales = true
        Lurker::RenderingController.prepend_view_path templates_root
        Lurker::RenderingController.config.assets_dir = assets_root
      end

      def prepare_assets!
        directory assets_root, '.', exclude_pattern: /application\.(js|css)$/
        digest_asset!('application.js')
        digest_asset!('application.css')
      end

      def cleanup_assets!
        actual = assets.values
        Dir.glob('*.{js,css,gz}').each do |fname|
          remove_file fname unless actual.include? fname.sub(/\.gz/, '')
        end
      end

      def digest_asset!(name)
        if (asset_path = assets_root + name).exist?
          digest_path = asset_digest_path(asset_path).basename
          assets[asset_path.basename.to_s] = digest_path.to_s
          copy_file asset_path, digest_path, skip: true
          spawn "cat #{digest_path} | gzip -9 > #{digest_path}.gz"
        end
      end

      def service_presenter
        @service_presenter ||= Lurker::ServicePresenter.new(Lurker.service, html_options, &filtering_block)
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
            static_html: true,
            url_base_path: url_base_path.prepend('/'),
            template_directory: templates_root,
            assets_directory: assets_root,
            assets: assets,
            html_directory: output_path,
            footer: footer,
            lurker: gem_info
        }
      end
    end

    private

    def output_path
      "#{output_prefix}/#{url_base_path}"
    end

    def output_prefix
      if explicit = options[:output]
        explicit.sub(/\/?#{url_base_path}\/?$/, '')
      elsif File.exists? 'public'
        'public'
      else
        raise 'Please, run it from `Rails.root` or pass `-o` option'
      end
    end

    def url_base_path
      options[:url_base_path].presence.try(:strip).try(:sub, /^\/+/, '') || Lurker::DEFAULT_URL_BASE
    end

    def assets
      @assets ||= {}
    end

    def assets_root
      Lurker::Cli.assets_root
    end

    def templates_root
      Lurker::Cli.templates_root
    end

    def asset_logical_path(path)
      path = Pathname.new(path) unless path.is_a? Pathname
      path.sub %r{-[0-9a-f]{40}\.}, '.'
    end

    def asset_digest_path(path)
      path = Pathname.new(path) unless path.is_a? Pathname
      asset_logical_path(path).sub(/\.(\w+)$/) { |ext| "-#{hexdigest(path)}#{ext}" }
    end

    def hexdigest(path)
      Digest::SHA1.hexdigest(open(path).read)
    end

    def path_extnames(path)
      File.basename(path).scan(/\.[^.]+/)
    end

    def footer
      `git rev-parse --short HEAD`.to_s.strip
    rescue
      ''
    end

    def gem_info
      spec = if Bundler.respond_to? :locked_gems
               Bundler.locked_gems.specs.select { |s| s.name == 'lurker' }.first # 1.6
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
      'lurker (unknown)'
    end
  end
end
