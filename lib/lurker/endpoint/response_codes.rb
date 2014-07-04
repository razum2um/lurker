module Lurker
  class Endpoint
    class ResponseCodes
      RESPONSE_CODES = 'responseCodes'.freeze
      DESCRIPTION = 'description'.freeze
      SUCCESSFUL = 'successful'.freeze
      STATUS = 'status'.freeze

      def initialize(schema)
        @schema = schema
        @schema[RESPONSE_CODES] ||= []
      end

      def add(options)
        response_code = {
          STATUS => options.fetch(:status_code),
          SUCCESSFUL => options.fetch(:successful),
          DESCRIPTION => options.fetch(:description, '')
        }

        Lurker::SchemaModifier.append!(@schema[RESPONSE_CODES], response_code)
      end

      def exists?(options)
        status_code = options.fetch(:status_code)
        successful = options.fetch(:successful)

        !!@schema[RESPONSE_CODES].detect do |response_code|
          response_code[SUCCESSFUL] == successful &&
            (response_code[STATUS] == status_code ||    # 200
             response_code[STATUS].to_i == status_code) # "200 OK"
        end
      end
    end
  end
end
