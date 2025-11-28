# config/initializers/omniauth.rb

OmniAuth.config.allowed_request_methods = [:post, :get]
OmniAuth.config.silence_get_warning = true

# Only disable CSRF in development, keep it in production
if Rails.env.development?
  OmniAuth.config.request_validation_phase = Proc.new {}
else
  # In production, you might want some validation
  OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection
end



