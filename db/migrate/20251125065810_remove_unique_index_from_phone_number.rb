class RemoveUniqueIndexFromPhoneNumber < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :phone_number, true
    change_column_default :users, :phone_number, nil
  end
  
  
end
