module CustomerSerilizers
class CustomerProfileShowSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers
  
    attributes :full_name,
               :phone_number,
               :address,
               :latitude,
               :gender,
               :longitude,
               :profile_image,
               :user_id

  
    def profile_image
      return nil unless object.profile_image.attached?
      rails_blob_url(object.profile_image, only_path: false)
    end
  end
end


