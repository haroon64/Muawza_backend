class CreateVendorPortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :vendor_portfolios do |t|
      t.references :vendor_profile, null: false, foreign_key: true
      t.text :work_experience

      t.timestamps
    end
  end
end
