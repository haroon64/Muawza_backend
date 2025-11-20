class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :sub_service, null: false, foreign_key: true
      t.references :customer_profile, null: false, foreign_key: true
      t.integer :booking_status, null: false, default: 0
      t.date :scheduled_date, null: false
      t.time :scheduled_time, null: false
      t.text :customer_notes

      t.timestamps
    end
    add_index :bookings, [:sub_service_id, :scheduled_date, :scheduled_time], name: "index_bookings_on_sub_service_and_schedule"
  end
end
