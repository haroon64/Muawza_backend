class ApplicationController < ActionController::API
  include ActionController::RequestForgeryProtection
  skip_forgery_protection

  def current_user
    header = request.headers["Authorization"]
    token = header&.split&.last

    # Return nil if token is blank, missing, or the string "null"
    return nil if token.blank? || token == "null"

    begin
      decoded = JwtService.decode(token)
      if decoded.is_a?(Hash) && decoded["user_id"]
        user_id = decoded["user_id"]
        @current_user ||= User.find(user_id)
      else
        nil
      end
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      nil
    end
  end
end
