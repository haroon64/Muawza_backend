class ApplicationController < ActionController::API
    include ActionController::RequestForgeryProtection
    skip_forgery_protection
    # include ApiAuthentication

    # Skip authentication for public routes like login/signup
    # skip_before_action :authenticate_user_from_token!, only: [:login, :signup]

    # skip_forgery_protection 

def current_user
        header = request.headers['Authorization']
        token = header.split.last if header
      
        begin
          decoded = JWT.decode(token, Rails.application.credentials.secret_key_base)[0]
          user_id = decoded["sub"] # or decoded["user_id"]
          @current_user ||= User.find(user_id)
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          nil
        end
    end
      
end
