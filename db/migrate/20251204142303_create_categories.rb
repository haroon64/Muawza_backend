class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :sub_service_name, null: false
      t.references :service, null: false, foreign_key: true
      t.timestamps
    end
  end
end
