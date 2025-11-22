class Api::V1::Services::SubServicesController < ApplicationController
  include Rails.application.routes.url_helpers
#   include ApiAuthentication

  # Uncomment this if you want set_sub_service before show, update, destroy
  # before_action :set_sub_service, only: [:show, :update, :destroy]

  # GET /api/v1/sub_services
  def index
    sub_services = SubService.all

    # FILTERS
    sub_services = sub_services.where(city: params[:city]) if params[:city].present?
    
    if params[:sub_service_name].present?
      sub_services = sub_services.where("sub_service_name ILIKE ?", "%#{params[:sub_service_name]}%")
    end

    # Add filter for service_name by joining Service
    if params[:service_name].present?
      sub_services = sub_services.joins(:service).where("services.service_name ILIKE ?", "%#{params[:service_name]}%")
    end

    if params[:price_min].present? && params[:price_max].present?
      sub_services = sub_services.where(price: params[:price_min]..params[:price_max])
    end

    # PAGINATION
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i

    paginated_sub_services = sub_services.page(page).per(per_page)

    meta = {
      current_page: paginated_sub_services.current_page,
      total_pages: paginated_sub_services.total_pages,
      total_count: paginated_sub_services.total_count
    }

    # RENDER JSON using each_serializer, not with plain serializer
    render json: paginated_sub_services, 
           each_serializer: ServiceSerilalizers::SubServiceShowSerializer,
           meta: meta,
           status: :ok
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
  def search_by_city
    city = params[:city]

    if city.blank?
      render json: { errors: ["Please provide a city parameter."] }, status: :bad_request and return
    end

    sub_services = SubService.where(city: city)

    if sub_services.any?
      render json: sub_services, each_serializer: ServiceSerilalizers::SubServiceIndexSerializer, status: :ok
    else
      render json: { message: "No  services found for city '#{city}'." }, status: :not_found
    end
  end

  def create
    puts "inside create"
    user_id = params[:user_id]
    vendor_profile = VendorProfile.find_by(user_id: user_id)
    unless vendor_profile
      render json: { errors: ["Vendor profile not found for given user_id"] }, status: :not_found and return
    end

    # Exclude :user_id and :cover_image since they are not model columns
    sub = SubService.new(sub_service_params.except(:user_id, :cover_image).merge(vendor_profile_id: vendor_profile.id))
    # Handle ActiveStorage cover image attachment if provided
    if params[:cover_image].present?
      sub.sub_service_image.attach(params[:cover_image])
    end

    if sub.save
      render json: ServiceSerilalizers::SubServiceCreateSerializer.new(sub).serializable_hash, status: :created
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
    params.permit(:service_id, :user_id, :sub_service_name, :description, :city, :price, :price_bargain, :active_status, :cover_image)
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