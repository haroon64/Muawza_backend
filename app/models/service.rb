class Service < ApplicationRecord
  has_many :sub_services, dependent: :destroy
  has_one_attached :icon
  has_many :categories
end
