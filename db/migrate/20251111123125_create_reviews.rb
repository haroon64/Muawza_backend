class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :sub_service, null: false, foreign_key: true
      t.references :customer_profile, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end
    add_index :reviews, [:sub_service_id, :customer_profile_id], name: "index_reviews_on_sub_service_and_customer"
  end
end
