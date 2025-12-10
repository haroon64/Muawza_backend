# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      puts "ActionCable: connection requested"
      self.current_user = find_verified_user
      puts "ActionCable connected: #{current_user.inspect}"
    end

    private

    def find_verified_user
      token = request.params[:token]
      puts "[ActionCable] token present? #{token.present?}"

      if token.present?
        begin
          # Use your JWT service here instead of manual JWT.decode
          payload = JwtService.decode(token)  # <-- replace with your service
          user_id = payload["user_id"]
          user = User.find_by(id: user_id)

          if user
            puts "[ActionCable] User verified via JWT: #{user.inspect}"
            return user
          end
        rescue StandardError => e
          puts "[ActionCable] JWT decode error: #{e.message}"
          reject_unauthorized_connection
        end
      end

      reject_unauthorized_connection
    end
  end
end
