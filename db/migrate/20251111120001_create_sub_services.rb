class CreateSubServices < ActiveRecord::Migration[8.0]
  def change
    create_table :sub_services do |t|
      t.references :service, null: false, foreign_key: true
      t.string :sub_service_name, null: false
      t.text :description, null: false
      t.integer :price, null: false
      t.integer :price_bargain
      t.boolean :active_status, null: false, default: true

      t.timestamps
    end
  end
end
