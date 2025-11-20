class ApplicationController < ActionController::API
    include ActionController::RequestForgeryProtection

    skip_forgery_protection 

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
