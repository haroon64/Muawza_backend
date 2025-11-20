class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :service_name, :icon_url

  def icon_url
    Rails.application.routes.url_helpers.  rails_blob_url(object.icon, host: "#{ENV['BACKEND_URL']}") if object.icon.attached?
  end
end
