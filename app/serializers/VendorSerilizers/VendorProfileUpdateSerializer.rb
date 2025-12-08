module VendorSerilizers
class VendorProfileUpdateSerializer
  def initialize(vendor_profile)
    @vendor_profile = vendor_profile
  end

  def as_json
    {
      id: @vendor_profile.id,
      full_name: @vendor_profile.full_name,
      phone_number: @vendor_profile.phone_number,
      second_phone_number: @vendor_profile.second_phone_number,
      address: @vendor_profile.address,
      latitude: @vendor_profile.latitude,
      longitude: @vendor_profile.longitude,
      profile_image: profile_image_url,
      vendor_portfolios: serialize_portfolios
    }
  end

  private

  def profile_image_url
    return nil unless @vendor_profile.profile_image.attached?

    Rails.application.routes.url_helpers.url_for(@vendor_profile.profile_image)
  end

  def serialize_portfolios
    @vendor_profile.vendor_portfolios.map do |portfolio|
      {
        id: portfolio.id,
        work_experience: portfolio.work_experience,
        images: serialize_images(portfolio)
      }
    end
  end

  def serialize_images(portfolio)
    portfolio.images.map do |image|
      {
        id: image.id,
        url: Rails.application.routes.url_helpers.url_for(image)
      }
    end
  end
end
end
