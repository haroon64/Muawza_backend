
module ConversationSerializers
  class ConversationShowSerializer < ActiveModel::Serializer
    attributes :id, :customer_id, :vendor_id,  :vendor_profile

    # def customer_profile
    #   customer = CustomerProfile.find_by(id: object.customer_id)
    #   if customer
    #     {
    #       id: customer.id,
    #       full_name: customer.full_name,
    #       profile_image: customer.profile_image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(customer.profile_image, only_path: true) : nil
    #     }
    #   else
    #     nil
    #   end
    # end

    def vendor_profile
      vendor = VendorProfile.find_by(id: object.vendor_id)
      if vendor
        {
          id: vendor.id,
          full_name: vendor.full_name,
          profile_image: vendor.profile_image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(vendor.profile_image, only_path: true) : nil
        }
      else
        nil
      end
    end
  end
end
