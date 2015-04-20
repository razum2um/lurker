module Lurker
  module Json
    class ResponseCodes < Schema
      STATUS = 'status'.freeze
      SUCCESSFUL = 'successful'.freeze

      def initialize(schema, options = {})
        @parent_property = 'responseCodes'

        super
      end

      def merge!(status_code, successful)
        return if exists?(status_code, successful)

        payload = {STATUS => status_code, SUCCESSFUL => successful, Json::DESCRIPTION => ''}
        @schema << Lurker::Json::Parser.plain(root_schema: root_schema).parse(payload)
      end

      def validate!(status_code, successful)
        return if exists?(status_code, successful)

        raise Lurker::UndocumentedResponseCode,
          'Undocumented response: %s, successful: %s' % [
            status_code, successful
          ]
      end

      def exists?(status_code, successful)
        !!@schema.detect do |response_code|
          response_code[SUCCESSFUL] == successful &&
            (response_code[STATUS] == status_code ||    # 200
             response_code[STATUS].to_i == status_code) # "200 OK"
        end
      end

      def statuses
        @schema.map { |response_code| response_code[STATUS].to_i }
      end
    end
  end
end
