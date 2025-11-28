class SubService < ApplicationRecord
  belongs_to :service
  belongs_to :vendor_profile
  has_many :service_areas, dependent: :destroy
  has_many :service_availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_one :address

  has_one_attached :sub_service_image
  has_one :address, dependent: :destroy

  # scope :by_city, ->(city) { where(city: city) }
  # validate :vendor_profile_must_exist, on: :create
  validate :description
  validate :sub_service_name
  enum :price_bargain, { fixed: 0, negotiable: 1 }
  private

  # def vendor_profile_must_exist

  #   unless VendorProfile.exists?(service_id: self.service_id)
  #     errors.add(:base, "Vendor profile must exist before creating a subservice")
  #   end
  # end
end
