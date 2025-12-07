class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
     stream_from "chat_room_#{params[:chat_room_id]}"
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
