require 'sinatra/base'
require 'rack'

module Lurker
  class Server
    # fixed rack_contrib implementation
    class TryStatic
      def initialize(app, options)
        @app = app
        @try = ['', *options.delete(:try)]
        @static = ::Rack::Static.new(
          proc { [404, {}, []] }, # HERE proc, not lambda
          options)
      end

      def call(env)
        orig_path = env['PATH_INFO']
        found = nil
        @try.each do |path|
          resp = @static.call(env.merge!('PATH_INFO' => orig_path + path))
          break if 404 != resp[0] && found = resp
        end
        found or @app.call(env.merge!('PATH_INFO' => orig_path))
      end
    end

    def self.to_rack(options = {})
      Rack::Builder.app do
        document_root = options[:path] || Lurker::DEFAULT_DOCUMENT_ROOT

        if !Rails.env.development? && (username, password = options.values_at(:username, :password)).all?(&:present?)
          use ::Rack::Auth::Basic, "Protected Area" do |u, p|
            username == u && password == p
          end
        end

        use ::Rack::Deflater

        use TryStatic,
         :root => "#{::Rails.root}/#{document_root}",  # static files root dir
         :urls => %w[/],     # match all requests
         :header_rules => [
           [%w(css js), { 'Cache-Control' => 'public, max-age=31536000' }],
           [:fonts, { 'Access-Control-Allow-Origin' => '*' }]
         ],
         :try => ['.html', 'index.html', '/index.html'] # try these postfixes sequentially

         run Proc.new { |env|
           [404, { "Content-Type" => "text/html" }, ["File not lurked: #{env['PATH_INFO']}\n"]]
         }
      end
    end
  end
end

