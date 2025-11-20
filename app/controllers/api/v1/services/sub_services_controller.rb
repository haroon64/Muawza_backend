class Api::V1::Services::SubServicesController < ApplicationController
    include Rails.application.routes.url_helpers
  
    before_action :set_sub_service, only: [:show, :update, :destroy]
  
    # GET /api/v1/sub_services
    def index
      sub_services = SubService.all
      render json: sub_services.map { |s| serialize_sub_service(s) }
    end
  
    # GET /api/v1/sub_services/:id
    def show
      render json: serialize_sub_service(@sub_service)
    end
  
    # POST /api/v1/sub_services
    def create
      sub = SubService.new(sub_service_params)
  
      if sub.save
        attach_images(sub)
        render json: serialize_sub_service(sub), status: :created
      else
        render json: { errors: sub.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # PUT/PATCH /api/v1/sub_services/:id
    def update
      if @sub_service.update(sub_service_params)
        attach_images(@sub_service)
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
      params.permit(:service_id, :sub_service_name, :description, :price, :price_bargain, :active_status)
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
  