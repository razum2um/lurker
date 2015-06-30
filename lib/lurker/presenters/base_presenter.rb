require 'erb'
require 'json'
require 'forwardable'

class Lurker::BasePresenter
  attr_reader :options

  def initialize(options = {})
    @options = options
  end

  def html_directory
    options[:url_base_path] || options[:html_directory] || ""
  end

  def url_base_path
    options[:url_base_path] || '/'
  end

  def assets
    options[:assets] || {}
  end

  def asset_path(asset)
    "#{html_directory}/#{assets[asset] || asset}"
  end

  def index_path(subdirectory = "")
    html_path = File.join(html_directory, subdirectory)
    if options[:static_html]
      File.join(html_path, 'index.html')
    else
      html_path
    end
  end

  def tag_with_anchor(tag, content, anchor_slug = nil)
    anchor_slug ||= content.downcase.gsub(' ', '_')
    <<-EOS
    <#{tag} id="#{anchor_slug}">
      <a href="##{anchor_slug}" class="anchor">
        #{content}
      </a>
    </#{tag}>
    EOS
  end

  def markup(content)
    Lurker.safe_require 'kramdown'
    defined?(Kramdown) ? Kramdown::Document.new(content).to_html : content
  end
end
