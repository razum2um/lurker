require 'ostruct'
require 'abstract_controller'
require 'action_view'
require 'action_dispatch/http/mime_type'

module Lurker
  class RenderingController < ::AbstractController::Base
    # Include all the concerns we need to make this work
    include AbstractController::Helpers
    include AbstractController::Rendering
    include ActionView::Rendering if defined?(ActionView::Rendering)
    include ActionView::Layouts if defined?(ActionView::Layouts) # Rails 4.1.x
    include AbstractController::Layouts if defined?(AbstractController::Layouts) # Rails 3.2.x, 4.0.x
    include ActionView::Context

    self.view_paths = File.join(File.dirname(__FILE__), "templates")

    # Define additional helpers, this one is for csrf_meta_tag
    helper_method :protect_against_forgery?, :tag_with_anchor

    # override the layout in your subclass if needed.
    layout 'application'

    # we are not in a browser, no need for this
    def protect_against_forgery?
      false
    end

    def tag_with_anchor(tag, content, anchor_slug = nil)
      anchor_slug ||= content.downcase.gsub(' ', '_')
      <<-EOS
      <#{tag} id="#{anchor_slug}">
        <a href="##{anchor_slug}" class="anchor">
          #{content}
        </a>
      </#{tag}>
      EOS
    end

    # so that your flash calls still work
    def flash
      {}
    end

    # and nil request to differentiate between live and offline
    def request
      OpenStruct.new
    end

    # and params will be accessible
    def params
      {}
    end

    # so that your cookies calls still work
    def cookies
      {}
    end

  end
end
