require 'lurker/server'

module Lurker
  class Engine < ::Rails::Engine
    config.after_initialize do |app|
      app.routes.prepend do
        mount Lurker::Server.to_rack(path: 'html'), at: '/lurker'
      end
    end
  end
end
