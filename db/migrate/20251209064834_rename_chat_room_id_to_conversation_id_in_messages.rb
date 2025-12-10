class RenameChatRoomIdToConversationIdInMessages < ActiveRecord::Migration[8.0]
  def change
    rename_column :messages, :chat_room_id, :conversation_id
  end
end
