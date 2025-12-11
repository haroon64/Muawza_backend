module ApplicationCable
  class Channel < ActionCable::Channel::Base
    def current_user
      connection.current_user
    end

    protected

    def broadcast_error(message)
      transmit({ type: "error", message: message })
    end
  end
end
