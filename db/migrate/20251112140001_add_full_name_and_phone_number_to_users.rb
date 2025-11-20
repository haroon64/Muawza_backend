class AddFullNameAndPhoneNumberToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string, null: false, default: ""
    add_column :users, :phone_number, :string, null: false, default: ""

    add_index :users, :phone_number, unique: true
  end
end
