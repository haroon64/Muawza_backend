class Conversation < ApplicationRecord
  belongs_to :sub_service
  belongs_to :customer_profile, foreign_key: "customer_id"
  belongs_to :vendor_profile, foreign_key: "vendor_id"

  has_many :messages, dependent: :destroy

  # validates :customer_id, uniqueness: { scope: :vendor_id }
end
