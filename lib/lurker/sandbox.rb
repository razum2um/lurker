module Lurker
  class Sandbox
    def initialize(app)
      @app = app
    end

    def call(env)
      orig_path = env['PATH_INFO']
      if orig_path.ends_with?('.js') || orig_path.ends_with?('css') || orig_path.ends_with?('css.map')
        @result = @app.call(env)
      else
        ActiveRecord::Base.transaction do
          @result = @app.call(env)
          raise ActiveRecord::Rollback if called_from_lurker?(env)
        end
      end
      @result
    end

    private

    def called_from_lurker?(env)
      return false if (referer = env['HTTP_REFERER']).blank?
      url = URI.parse referer
      url.path.starts_with? "/#{Lurker::DEFAULT_URL_BASE}"
    end
  end
end

