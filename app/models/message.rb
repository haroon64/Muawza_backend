class Message < ApplicationRecord
  belongs_to :chat_room
  belongs_to :sender, class_name: "User"
end
