class Conversation < ApplicationRecord
  belongs_to :customer_profile, foreign_key: "customer_id"
  belongs_to :vendor_profile, foreign_key: "vendor_id"

  has_many :messages
end
