module Lurker
  module Json
    class Reader
      attr_reader :path

      def initialize(path)
        @path = path
        @attempts_left = 1
      end

      def read
        return YAML.load_file(@path) unless @path.match(/\.erb$/)

        context = Lurker::ErbSchemaContext.new
        erb = ERB.new(IO.read @path).result(context.get_binding)
        YAML.load(erb)
      rescue Errno::ENOENT
        raise if @attempts_left.zero?

        @path = @path.sub(/\#\/?$/, '').sub(/\.json/, '.json.yml')
        @attempts_left -= 1

        retry
      end
      alias_method :payload, :read
    end
  end
end
