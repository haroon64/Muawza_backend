class CreateCustomerProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :customer_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :phone_number, null: false

      t.timestamps
    end
    add_index :customer_profiles, :full_name, unique: true
    add_index :customer_profiles, :address, unique: true
    add_index :customer_profiles, :phone_number, unique: true
  end
end
