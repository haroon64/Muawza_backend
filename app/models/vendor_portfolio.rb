class VendorPortfolio < ApplicationRecord
  belongs_to :vendor_profile
  has_many_attached :images
end
