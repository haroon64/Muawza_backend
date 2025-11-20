class SubService < ApplicationRecord
  belongs_to :service
  has_many :service_areas, dependent: :destroy
  has_many :service_availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :vendor_profiles


  has_one_attached :sub_service_image
end
