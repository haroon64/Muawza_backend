class AddUniqueIndexToConversations < ActiveRecord::Migration[8.0]
  def change
     add_index :conversations, [ :customer_id, :vendor_id, :sub_service_id ], unique: true, name: "index_conversations_unique_triplet"
  end
end
