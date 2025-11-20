class CreateVendorProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name, null: false
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :phone_number, null: false
      t.string :second_phone_number
      t.timestamps
    end
    add_index :vendor_profiles, :full_name, unique: true
    add_index :vendor_profiles, :address, unique: true
    add_index :vendor_profiles, :phone_number, unique: true
  end
end
