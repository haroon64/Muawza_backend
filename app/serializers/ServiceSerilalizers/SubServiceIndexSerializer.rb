module ServiceSerilalizers
  class SubServiceIndexSerializer < ActiveModel::Serializer
    include Rails.application.routes.url_helpers

    attributes :id, :sub_service_name, :description, :price, :price_bargain, :city, :active_status, :created_at, :updated_at, :cover_image_url, :service_name, :service_id

    def cover_image_url
      return nil unless object.sub_service_image.attached?
      rails_blob_url(object.sub_service_image, only_path: false)
    end

    def service_name
      object.service&.service_name
    end
  end
end