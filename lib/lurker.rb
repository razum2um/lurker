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

  def self.valid_service_path?
    Dir.exist? service_path
  end

  def self.service
    @service ||= Lurker::Service.new(service_path)
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
require 'lurker/ref_object'
require 'lurker/erb_schema_context'
require 'lurker/service'
require 'lurker/validator'
require 'lurker/validation_error'
require 'lurker/utils'
require 'lurker/endpoint'
require 'lurker/rendering_controller'
require 'lurker/form_builder'
require 'lurker/presenters/json_presenter'
require 'lurker/presenters/base_presenter'
require 'lurker/presenters/service_presenter'
require 'lurker/presenters/endpoint_presenter'
require 'lurker/presenters/schema_presenter'
require 'lurker/presenters/response_code_presenter'
require 'lurker/json'
require 'lurker/json/reader'
require 'lurker/json/writer'
require 'lurker/json/orderer'
require 'lurker/json/parser'
require 'lurker/json/parser/expertise'
require 'lurker/json/parser/plain_strategy'
require 'lurker/json/parser/typed_strategy'
require 'lurker/json/concerns/validatable'
require 'lurker/json/schema'
require 'lurker/json/schema/object'
require 'lurker/json/schema/list'
require 'lurker/json/schema/attribute'
require 'lurker/json/schema/polymorph'
require 'lurker/json/schema/tuple'
require 'lurker/json/schema/tuple/all_of'
require 'lurker/json/schema/tuple/any_of'
require 'lurker/json/schema/tuple/one_of'
require 'lurker/json/schema/extensions'
require 'lurker/json/schema/response_codes'
require 'lurker/json/schema/reference'
require 'lurker/spy'
require 'lurker/server'
require 'lurker/request'
require 'lurker/response'

if defined? Rails
  require 'lurker/sandbox'
end
