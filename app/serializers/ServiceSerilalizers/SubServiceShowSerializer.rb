module ServiceSerilalizers
  class SubServiceShowSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :service_id, :service_name, :sub_service_name, :description,
               :price, :price_bargain, :active_status,
               :cover_image_url,
               :vendor_profile, :address

    def address
      return nil unless object.address.present?

      {
        city: object.address.city,
        longitude: object.address.longitude,
        latitude: object.address.latitude,
        address: object.address.address,
      }
    end

    def service_name
      object.service.try(:service_name)
    end

    def vendor_profile
      {
        id: object.vendor_profile.id,
        full_name: object.vendor_profile.full_name,
        phone_number: object.vendor_profile.phone_number,
        profile_image: profile_image_url(object.vendor_profile)
      }
    end

    def profile_image_url(vendor_profile)
      return nil unless vendor_profile.profile_image.attached?
      rails_blob_url(vendor_profile.profile_image, only_path: false)
    end

    def cover_image_url
      return nil unless object.sub_service_image.attached?
      rails_blob_url(object.sub_service_image, only_path: false)
    end
  end
end
