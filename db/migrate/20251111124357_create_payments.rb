class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :processor_identifier
      t.string :transaction_reference
      t.decimal :amount
      t.integer :status
      t.string :method
      t.decimal :processor_fee
      t.decimal :net_amount

      t.timestamps
    end
  end
end
