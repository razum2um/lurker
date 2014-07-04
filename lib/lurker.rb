$:.unshift(File.dirname(__FILE__))

module Lurker
  DEFAULT_SERVICE_PATH = DEFAULT_URL_BASE = "lurker".freeze
  LURKER_UPGRADE = "LURKER_UPGRADE".freeze

  def self.safe_require(gem, desc=nil)
    begin
      require gem
    rescue LoadError => e
      $stderr.puts(e.message)
      $stderr.puts(desc) if desc
      $stderr.puts("Please, bundle `gem #{gem}` in your Gemfile")
      exit 1 unless block_given?
    end
    yield if block_given?
  end

  def self.upgrade?
    !!ENV[LURKER_UPGRADE]
  end

  def self.service_path=(service_path)
    @service_path = service_path
  end

  def self.service_path
    @service_path || DEFAULT_SERVICE_PATH
  end

  def self.decide_success_with(&block)
    @success_block = block
  end

  def self.decide_success(*args)
    if @success_block
      @success_block.call(*args)
    else
      true
    end
  end

  # Top-level lurker validation error, abstract.
  class ValidationError < StandardError; end

  # Indicates an unknown response code.
  class UndocumentedResponseCode < ValidationError; end
end

require 'lurker/jaml_descriptor'
require 'lurker/schema'
require 'lurker/json_schema_hash'
require 'lurker/schema_modifier'
require 'lurker/schema_modifier/hash'
require 'lurker/schema_modifier/array'
require 'lurker/schema_modifier/atom'
require 'lurker/ref_object'
require 'lurker/erb_schema_context'
require 'lurker/service'
require 'lurker/validator'
require 'lurker/validation_error'
require 'lurker/endpoint'
require 'lurker/endpoint/response_codes'
require 'lurker/rendering_controller'
require 'lurker/form_builder'
require 'lurker/presenters/json_presenter'
require 'lurker/presenters/base_presenter'
require 'lurker/presenters/service_presenter'
require 'lurker/presenters/endpoint_presenter'
require 'lurker/presenters/schema_presenter'
require 'lurker/presenters/response_code_presenter'
require 'lurker/spy'
require 'lurker/request'
require 'lurker/response'

if defined? Rails
  require 'lurker/engine'
  require 'lurker/sandbox'
end
