class Booking < ApplicationRecord
  belongs_to :service
  belongs_to :customerProfile
  has_one :payment, dependent: :destroy
  enum booking_status: { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
end
