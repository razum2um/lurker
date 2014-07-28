require 'erb'
require 'json'
class Lurker::JsonPresenter
  attr_reader :json

  def initialize(json)
    @json = json
  end

  def to_html
    if json.is_a? String
      '<tt>&quot;%s&quot;</tt>' % json.gsub(/\"/, 'quot;')
    elsif json.is_a?(Numeric) ||
          json.is_a?(TrueClass) ||
          json.is_a?(FalseClass)
      '<tt>%s</tt>' % json
    elsif json.is_a?(Hash) ||
          json.is_a?(Array)
      '<pre><code>%s</code></pre>' % JSON.pretty_generate(json)
    end
  end
end
