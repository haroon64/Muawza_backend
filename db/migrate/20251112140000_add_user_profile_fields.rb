class AddUserProfileFields < ActiveRecord::Migration[8.0]
  def change
   
    add_column :users, :role, :integer, null: false, default: 0
    # add_column :users, :phone_number  :string , null:false 

  
  end
end

