class Favourite < ApplicationRecord
  belongs_to :customer_profile
  belongs_to :sub_services
end
