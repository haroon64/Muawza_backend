class AddGenderToCustomerProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :customer_profiles, :gender, :integer
  end
end
