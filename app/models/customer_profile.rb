class CustomerProfile < ApplicationRecord
  belongs_to :user
  enum :gender, { male: 0, female: 1, other: 2 }

  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :favourites, dependent: :destroy

  has_one_attached :profile_image
  # Validations to ensure parameters are present and valid
  validates :user_id, presence: true
  validates :full_name, presence: true
  validates :address, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }
  validates :phone_number, presence: true
  validates :gender, inclusion: { in: genders.keys }, allow_nil: true
end
