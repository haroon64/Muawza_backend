class CreateChatRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :chat_rooms do |t|
      t.bigint :user_id1
      t.bigint :user_id2

      t.timestamps
    end
  end
end
