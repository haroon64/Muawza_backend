class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :service_name, null: false

      t.timestamps
    end
  end
end
