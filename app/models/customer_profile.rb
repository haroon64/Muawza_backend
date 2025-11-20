class CustomerProfile < ApplicationRecord
  belongs_to :user
  enum :gender, { male: 0, female: 1, other: 2 }

  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :favourites, dependent: :destroy

  has_one_attached :profile_image
end
