# app/lib/omniauth/strategies/google_oauth2_api.rb
require 'omniauth-google-oauth2'

module OmniAuth
  module Strategies
    class GoogleOauth2Api < GoogleOauth2
      # Skip CSRF verification for API

    end
  end
end