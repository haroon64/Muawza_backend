module VendorSerilizers
    class VendorProfileShowSerializer < ActiveModel::Serializer
      include Rails.application.routes.url_helpers
  
      attributes :phone_number,
                 :second_phone_number,
                 :address,
                 :latitude,
                 :longitude,
                 :profile_image,
                 :vendor_portfolio
  
      def profile_image
        return nil unless object.profile_image.attached?
        rails_blob_url(object.profile_image, only_path: false)
      end
  
      def vendor_portfolio
        object.vendor_portfolios.map do |vp|
          {
            id: vp.id,
            work_experience: vp.work_experience,
            images: vp.images.map { |img| rails_blob_url(img, only_path: false) }
          }
        end
      end
    end
  end
  