class AddVendorRefToSubservices < ActiveRecord::Migration[8.0]
  def change
    add_reference :sub_services, :vendor_profile, null: false, foreign_key: true
  end
end
