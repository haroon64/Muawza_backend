class Api::V1::Services::SubServicesController < ApplicationController
  include Rails.application.routes.url_helpers
  # include ApiAuthentication

  # Uncomment this if you want set_sub_service before show, update, destroy
  # before_action :set_sub_service, only: [:show, :update, :destroy]

  # GET /api/v1/sub_services
  def index
    puts "------------1"
    sub_services = SubService.all
    puts "------------2"
  
    # FILTERS
    if params[:city].present?
      sub_services = sub_services.joins(:address).where(addresses: { city: params[:city] })
    end
  
    if params[:sub_service_name].present?
      sub_services = sub_services.where("sub_service_name ILIKE ?", "%#{params[:sub_service_name]}%")
      puts "------------5"
    end
  
    if params[:service_name].present?
      sub_services = sub_services.joins(:service).where("services.service_name ILIKE ?", "%#{params[:service_name]}%")
      puts "------------6"
    end
  
    if params[:price_min].present? && params[:price_max].present?
      sub_services = sub_services.where(price: params[:price_min]..params[:price_max])
    end
  
    # NEW: Filter by radius (10 km)
    if params[:latitude].present? && params[:longitude].present?
      lat = params[:latitude].to_f
      lng = params[:longitude].to_f
      radius_km = 30
  
      # Haversine formula in SQL
      sub_services = sub_services.joins(:address).where(
        <<-SQL, lat: lat, lng: lng, radius: radius_km
          6371 * acos(
            cos(radians(:lat)) * cos(radians(addresses.latitude)) *
            cos(radians(addresses.longitude) - radians(:lng)) +
            sin(radians(:lat)) * sin(radians(addresses.latitude))
          ) <= :radius
        SQL
      )
    end
  
    puts "------------7"
  
    # PAGINATION
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
  
    paginated_sub_services = sub_services.page(page).per(per_page)
  
    # meta = {
    #   current_page: paginated_sub_services.current_page,
    #   total_pages: paginated_sub_services.total_pages,
    #   total_count: paginated_sub_services.total_count
    # }
  
    render json: {
      sub_services: ActiveModelSerializers::SerializableResource.new(
        paginated_sub_services, each_serializer: ServiceSerilalizers::SubServiceShowSerializer
      ),
      total_sub_services: SubService.count
    }, status: :ok
  end
  
  

  # GET /api/v1/sub_services/:id
  def show
    sub_service = SubService.find_by(id: params[:id])
  
    if sub_service
      render json: ServiceSerilalizers::SubServiceShowSerializer.new(sub_service).serializable_hash, status: :found
    else
      render json: { exists: false, message: "SubService not found" }, status: :not_found
    end
  end
  


  # Returns all subservices for a given service_id and includes the service_name in the response
  # GET /api/v1/services/:service_id/sub_services_by_service
  def sub_services_by_service

    service_id = params[:id]
    service = Service.find_by(id: service_id)

    unless service
      render json: { exists: false, message: "Service not found" }, status: :not_found and return
    end

    sub_services = SubService.where(service_id: service_id)
    render json: sub_services.map { |ss|
      ServiceSerilalizers::SubServiceShowSerializer.new(ss).serializable_hash
    }, status: :ok
  end
  # Search SubServices by city. Expects params[:city] in the request.
  # GET /api/v1/services/sub_services/search_by_city?city=CityName


  def create
    user_id = params[:user_id]
    vendor_profile = VendorProfile.find_by(user_id: user_id)

    unless vendor_profile
      render json: { errors: ["Vendor profile not found for given user_id"] },
             status: :not_found and return
    end

    # SubService model does NOT have a user_id attribute!
    # Only permit allowed attributes, DO NOT pass user_id to SubService.new

    # Remove :user_id from params permitted for SubService, only use vendor_profile_id
    sub_service_data = sub_service_params.except(:cover_image, :address, :city, :latitude, :longitude,:user_id)

    sub = SubService.new(sub_service_data.merge(vendor_profile_id: vendor_profile.id))
    puts "-----------6"
  
    # Attach image
    sub.sub_service_image.attach(params[:cover_image]) if params[:cover_image].present?

    if sub.save
      # Create Address directly from FormData if present
      if params[:address].present?
        sub.create_address(
          address: params[:address],
          city: params[:city],
          latitude: params[:latitude],
          longitude: params[:longitude]
        )
         puts "-----------7"
      end

      render json: ServiceSerilalizers::SubServiceCreateSerializer.new(sub).serializable_hash,
             status: :created
              puts "-----------8"

    else
      render json: { errors: sub.errors.full_messages }, status: :unprocessable_entity
    end
  end


  # PUT/PATCH /api/v1/sub_services/:id
  def update
    if @sub_service.update(sub_service_params.except(:cover_image))
      # Handle updating/changing cover image via ActiveStorage if provided
      if params[:cover_image].present?
        @sub_service.sub_service_image.purge if @sub_service.sub_service_image.attached?
        @sub_service.sub_service_image.attach(params[:cover_image])
      end
      render json: serialize_sub_service(@sub_service)
    else
      render json: { errors: @sub_service.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/sub_services/:id
  def destroy
    @sub_service.destroy
    render json: { message: "Sub Service deleted successfully" }
  end

  private

  def set_sub_service
    @sub_service = SubService.find(params[:id])
  end

  def sub_service_params
    params.permit(
      :service_id,
      :user_id,
      :sub_service_name,
      :description,
      :price,
      :price_bargain,
      :active_status,
      :cover_image,
      
      # Address fields sent individually
      :address,
      :city,
      :latitude,
      :longitude
    )
  end
  

  def attach_images(sub)
    return unless params[:images].present?
    params[:images].each do |img|
      sub.images.attach(img)
    end
  end

  def serialize_sub_service(sub)
    sub.as_json.merge({
      images: sub.images.map { |img| url_for(img) }
    })
  end
end