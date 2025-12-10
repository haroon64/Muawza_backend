
module ConversationSerializers
  class ConversationShowSerializer < ActiveModel::Serializer
    attributes :id, :customer_id, :vendor_id, :vendor_profile, :sub_service

    def sub_service
      sub_service = SubService.find_by(id: object.sub_service_id)
      if sub_service
        {
          id: sub_service.id,
          sub_service_name: sub_service.sub_service_name,
          price: sub_service.price,
          price_bargain: sub_service.price_bargain,
          sub_service_image: sub_service.sub_service_image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(sub_service.sub_service_image, only_path: true) : nil
        }
      else
        nil
      end
    end

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
