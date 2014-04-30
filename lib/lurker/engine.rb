require 'lurker/server'

module Lurker
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
      app.routes.append do
        unless ::Rails.env.production? || app.routes.routes.map(&:app).any? { |e| e.is_a?(Class) && e.name == 'Lurker::Rack' }
          mount Lurker::Server.to_rack(path: 'html'), at: "/#{Lurker::DEFAULT_URL_BASE}"
        end
      end
    end
  end
end
