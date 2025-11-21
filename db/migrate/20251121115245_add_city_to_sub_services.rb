class AddCityToSubServices < ActiveRecord::Migration[8.0]
  def change
    add_column :sub_services, :city, :string
  end
end
