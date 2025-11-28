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

  validate :must_have_at_least_one_portfolio

def must_have_at_least_one_portfolio
  if vendor_portfolios.empty?
    errors.add(:vendor_portfolios, "must include at least one portfolio")
  end
end

end
