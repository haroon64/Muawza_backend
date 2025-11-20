# config/initializers/session_store.rb (create this file)

Rails.application.config.session_store :cookie_store, 
  key: '_backend_session',
  same_site: :lax,  # Important for OAuth redirects
  secure: Rails.env.production?