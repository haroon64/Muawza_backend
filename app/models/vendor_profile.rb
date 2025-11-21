class VendorProfile < ApplicationRecord
  belongs_to :user


  has_many :sub_services, dependent: :destroy
  has_many :vendor_portfolios, dependent: :destroy
  accepts_nested_attributes_for :vendor_portfolios

              
  has_one_attached :profile_image, dependent: :destroy

  # Validations for attributes (add other necessary attributes)
  validates :profile_image, presence: true
#   validates :user_id, presence: true
#   validates :full_name, presence: true
  validates :address, presence: true
  validates :phone_number, presence: true
end
