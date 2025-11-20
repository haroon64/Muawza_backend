class Service < ApplicationRecord
  # belongs_to :vendor_profile

  has_many :sub_services, dependent: :destroy
  has_one_attached :icon
  belongs_to :vendor_profile
  
end
