class RenameChatRoomsToConversations < ActiveRecord::Migration[8.0]
  def change
    rename_table :chat_rooms, :conversations
  end
end
