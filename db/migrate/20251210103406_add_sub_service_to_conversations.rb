class AddSubServiceToConversations < ActiveRecord::Migration[8.0]
  def change
    add_reference :conversations, :sub_service, null: false, foreign_key: true
  end
end
