class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :address
      t.string :city
      t.decimal :latitude
      t.decimal :longitude
      t.references :sub_service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
