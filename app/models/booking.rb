class Booking < ApplicationRecord
  belongs_to :sub_services
  belongs_to :customer_profile
  has_one :payment, dependent: :destroy
  enum :booking_status, { pending: 0, confirmed: 1, completed: 2, cancelled: 3 }
  validates :booking_status, presence: true
  validates :scheduled_date, presence: true
  validates :scheduled_time, presence: true
  validates :customer_notes, presence: true
end
