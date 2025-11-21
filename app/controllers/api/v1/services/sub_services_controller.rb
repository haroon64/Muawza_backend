class Api::V1::Services::SubServicesController < ApplicationController
  include Rails.application.routes.url_helpers
    # before_action :set_sub_service, only: [:show, :update, :destroy]
    # GET /api/v1/sub_services
    def index
        puts "inside the index method "
      sub_services = SubService.all
      render json: sub_services, each_serializer: ServiceSerilalizers::SubServiceIndexSerializer

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
        render json: { message: "No sub services found for city '#{city}'." }, status: :not_found
      end
    end


    def create
      puts "inside create"
      user_id = params[:user_id]
      vendor_profile = VendorProfile.find_by(user_id: user_id)
        puts"----------vendor_profile"
      unless vendor_profile
        render json: { errors: ["Vendor profile not found for given user_id"] }, status: :not_found and return
      end

      # Exclude :user_id and :cover_image since they are not model columns
      sub = SubService.new(sub_service_params.except(:user_id, :cover_image).merge(vendor_profile_id: vendor_profile.id))
      puts "-------#{sub}"
      
      # Handle ActiveStorage cover image attachment if provided
      if params[:cover_image].present?
        sub.sub_service_image.attach(params[:cover_image])
      end
      puts "-------"

      if sub.save  
         puts "-------inside save"
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
      params.permit(:service_id,:user_id, :sub_service_name, :description, :price, :price_bargain, :active_status ,:cover_image)
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
  