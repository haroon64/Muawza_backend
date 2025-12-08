class RenameColumnsInChatRooms < ActiveRecord::Migration[8.0]
  def change
    rename_column :conversations, :user_id1, :customer_id
    rename_column :conversations, :user_id2, :vendor_id
  end
end
