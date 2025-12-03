class RemoveDefaultAndSetUniqueOnPhoneNumber < ActiveRecord::Migration[8.0]
  def change
    # 1. Remove the default value of ""
    change_column_default :users, :phone_number, nil

    # 2. Change the 'null' constraint to allow NULL (it was previously set to false)
    change_column_null :users, :phone_number, true
    # 3. Add a unique index, which allows multiple NULL values (standard behavior in PostgreSQL and MySQL)
    add_index :users, :phone_number, unique: true, name: 'index_users_on_phone_number_unique'

  end
end
