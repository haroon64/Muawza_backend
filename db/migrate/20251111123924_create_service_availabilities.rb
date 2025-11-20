class CreateServiceAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :service_availabilities do |t|
      t.references :sub_service, null: false, foreign_key: true
      t.date :date, null: false
      t.string :time_slot, null: false
      t.boolean :available, null: false, default: true

      t.timestamps
    end
    add_index :service_availabilities, [:sub_service_id, :date, :time_slot], unique: true, name: "index_service_availabilities_on_schedule"
  end
end
