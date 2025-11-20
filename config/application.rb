# config/application.rb

require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Backend
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    # Proper session setup for OAuth
    config.session_store :cookie_store, 
      key: '_backend_session',
      same_site: :lax,
      secure: Rails.env.production?,
      httponly: true

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options
    

    config.autoload_lib(ignore: %w[assets tasks])
  end
end