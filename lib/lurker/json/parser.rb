module Lurker
  module Json
    class Parser

      class << self
        def plain(options = {})
          new(options).plain
        end

        def typed(options = {})
          new(options).typed
        end
      end

      def initialize(options = {})
        @root_schema = options[:root_schema]
        @parent_schema = options[:parent_schema]
        @parent_property = options[:parent_property]
        @uri = options[:uri] || @parent_schema.try(:uri)
        @strategy = nil
      end

      def parse(payload)
        parse_once { @strategy.new(schema_options_once).parse(payload) }
      end

      def parse_property(property, payload)
        options = schema_options_once.merge!(parent_property: property)
        parse_once { @strategy.new(options).parse(payload) }
      end

      def plain(options = {})
        @options = schema_options.merge!(options)
        @strategy = strategy_klass(:plain)
        self
      end

      def typed(options = {})
        @options = schema_options.merge!(options)
        @strategy = strategy_klass(:typed)
        self
      end

      private

      def parse_once(&block)
        raise 'Define parsing strategy [plain|typed] before using' unless @strategy.present?

        result = block.call
        @strategy = nil

        result
      end

      def schema_options_once
        options = @options.present? ? @options.dup : schema_options
        @options = {}

        options
      end

      def strategy_klass(name)
        "lurker/json/parser/#{name}_strategy".camelize.constantize
      end

      def schema_options
        {
          uri: @uri, root_schema: @root_schema,
          parent_schema: @parent_schema, parent_property: @parent_property
        }
      end

    end
  end
end
