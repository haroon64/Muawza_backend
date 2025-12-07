class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :body
      t.references :chat_room, null: false, foreign_key: true
      t.bigint :sender_id

      t.timestamps
    end
  end
end
