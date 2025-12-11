class DropPaymentTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :payments
  end
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
