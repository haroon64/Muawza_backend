class Api::V1::Services::ServiceIconsController < ApplicationController
    # include ApiAuthentication
    include Rails.application.routes.url_helpers
    before_action :set_service, only: [:show, :update, :destroy]

    def index
      services = Service.all
      render json: services ,each_serializer: ServiceSerializer
    end
  
    def show
      render json: services ,serializer: ServiceSerializer
    end
  
    def create
      service = Service.new(service_params)
  
      if service.save
        attach_images(service)
        render json: serialize_service(service), status: :created
      else
        render json: { errors: service.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def update
      if @service.update(service_params)
        attach_images(@service)
        render json: serialize_service(@service)
      else
        render json: { errors: @service.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def destroy
      @service.destroy
      render json: { message: "Service deleted successfully" }
    end
  
    private
  
    def set_service
      @service = Service.find(params[:id])
    end
  
    def service_params
      params.permit(:service_name)
    end
  
    def attach_images(service)
      return unless params[:icon].present?

      service.icon.attach(params[:icon])
 
    end

    def serialize_service(service)
      service.as_json.merge({
        icon: service.icon.attached? ? url_for(service.icon) : nil
      })
    end
  end
  