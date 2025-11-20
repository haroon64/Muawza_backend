class CreateFavourites < ActiveRecord::Migration[8.0]
  def change
    create_table :favourites do |t|
      t.references :customer_profile, null: false, foreign_key: true
      t.references :sub_service, null: false, foreign_key: true

      t.timestamps
    end
    add_index :favourites, [:customer_profile_id, :sub_service_id], unique: true, name: "index_favourites_on_customer_and_sub_service"
  end
end
