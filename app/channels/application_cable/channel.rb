module ApplicationCable
  class Channel < ActionCable::Channel::Base
    # Common methods for all channels

    def current_user
      puts "-----------------current user in channel"
      puts connection.inspect   # shows your Connection object
      puts connection.current_user.inspect
      connection.current_user
    end

    protected

    def broadcast_error(message)
      transmit({ type: "error", message: message })
    end
  end
end
