class RemoveUniqueIndexFromUsersFullName < ActiveRecord::Migration[8.0]
  def change
    remove_index :customer_profiles, :full_name, unique: true
    add_index :customer_profiles, :full_name
  end
end
