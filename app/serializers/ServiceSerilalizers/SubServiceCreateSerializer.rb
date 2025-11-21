module ServiceSerilalizers
  class SubServiceCreateSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :service_id, :sub_service_name, :description, :city ,
               :price, :price_bargain, :active_status,
               :created_at, :updated_at, :cover_image_url
            #    :vendor_profile 

    # Return the name of the service instead of its ID
    # def service_name
    #   object.service.try(:service_name) 
    # end

    # NESTED VENDOR PROFILE INFO
    def vendor_profile
      {
        id: object.vendor_profile.id,
        full_name: object.vendor_profile.full_name,
        phone_number: object.vendor_profile.phone_number,
        address: object.vendor_profile.address
      }
    end

    def cover_image_url
      return nil unless object.sub_service_image.attached?
      rails_blob_url(object.sub_service_image, only_path: false)
    end
  end
end