class RemoveCityFromSubServices < ActiveRecord::Migration[8.0]
  def change
    remove_column :sub_services, :city, :string
  end
end
