class Review < ApplicationRecord
  belongs_to :sub_services
  belongs_to :customer_profile
end
