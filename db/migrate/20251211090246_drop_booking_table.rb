class DropBookingTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :bookings
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
