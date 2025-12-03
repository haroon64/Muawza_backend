class Api::V1::Services::SubServicesController < ApplicationController
  include Rails.application.routes.url_helpers

  def index
    sub_services = SubService.all

    if params[:city].present?
      sub_services = sub_services.joins(:address).where(addresses: { city: params[:city] })
    end

    if params[:sub_service_name].present?
      sub_services = sub_services.where("sub_service_name ILIKE ?", "%#{params[:sub_service_name]}%")
    end

    if params[:service_name].present?
      sub_services = sub_services.joins(:service).where("services.service_name ILIKE ?", "%#{params[:service_name]}%")
    end

    if params[:price_min].present? && params[:price_max].present?
      sub_services = sub_services.where(price: params[:price_min]..params[:price_max])
    elsif params[:price_min].present?
      sub_services = sub_services.where("price >= ?", params[:price_min])
    elsif params[:price_max].present?
      sub_services = sub_services.where("price <= ?", params[:price_max])
    end

    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    paginated_sub_services = sub_services.order(created_at: :desc).page(page).per(per_page)

    render json: {
      sub_services: ActiveModelSerializers::SerializableResource.new(
        paginated_sub_services, each_serializer: ServiceSerilalizers::SubServiceShowSerializer
      ),
      total_sub_services: SubService.count
    }, status: :ok
  end

  def show
    sub_service = SubService.find_by(id: params[:id])

    if sub_service
      render json: ServiceSerilalizers::SubServiceShowSerializer.new(sub_service).serializable_hash,
             status: :found
    else
      render json: { exists: false, message: "SubService not found" }, status: :not_found
    end
  end

  def sub_services_by_service
    service_id = params[:id]
    service = Service.find_by(id: service_id)

    unless service
      render json: { exists: false, message: "Service not found" }, status: :not_found and return
    end

    sub_services = SubService.where(service_id: service_id)
    render json: sub_services.map {
      |ss| ServiceSerilalizers::SubServiceShowSerializer.new(ss).serializable_hash
    }, status: :ok
  end

  def create
    user_id = params[:user_id]
    vendor_profile = VendorProfile.find_by(user_id: user_id)

    unless vendor_profile
      render json: { errors: ["Vendor profile not found for given user_id"] },
             status: :not_found and return
    end

    sub_service_data = sub_service_params.except(:cover_image, :address, :city, :latitude, :longitude, :user_id)
    sub = SubService.new(sub_service_data.merge(vendor_profile_id: vendor_profile.id))
    sub.sub_service_image.attach(params[:cover_image]) if params[:cover_image].present?

    if sub.save
      if params[:address].present?
        sub.create_address(
          address: params[:address],
          city: params[:city],
          latitude: params[:latitude],
          longitude: params[:longitude]
        )
      end

      render json: ServiceSerilalizers::SubServiceCreateSerializer.new(sub).serializable_hash,
             status: :created
    else
      render json: { errors: sub.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @sub_service.update(sub_service_params.except(:cover_image))
      if params[:cover_image].present?
        @sub_service.sub_service_image.purge if @sub_service.sub_service_image.attached?
        @sub_service.sub_service_image.attach(params[:cover_image])
      end

      render json: serialize_sub_service(@sub_service)
    else
      render json: { errors: @sub_service.errors.full_messages }, status: :unprocessable_entity
    end
  end

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
      :service_id, :user_id, :sub_service_name, :description, :price,
      :price_bargain, :active_status, :cover_image, :address, :city,
      :latitude, :longitude
    )
  end

  def attach_images(sub)
    return unless params[:images].present?
    params[:images].each { |img| sub.images.attach(img) }
  end

  def serialize_sub_service(sub)
    sub.as_json.merge({
      images: sub.images.map { |img| url_for(img) }
    })
  end
end
