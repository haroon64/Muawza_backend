class Api::V1::Vendor::VendorProfilesController < ApplicationController
  include ApiAuthentication
  #  only: [:show, :update, :destroy]

  def index
    @vendors = VendorProfile.all
    render json: @vendors
  end

  def show
    profile = VendorProfile.find_by(user_id: params[:id])
    if profile
      render json: { exists: true, profile: VendorSerilizers::VendorProfileShowSerializer.new(profile).as_json }, status: :ok
    else
      render json: { exists: false, message: "Profile not found" }, status: :not_found
    end
  end

  def vendor_by_id
    profile = VendorProfile.find_by(id: params[:id])
    if profile
      render json: { exists: true, profile: VendorSerilizers::VendorProfileShowSerializer.new(profile).as_json }, status: :ok
    else
      render json: { exists: false, message: "Profile not found" }, status: :not_found
    end
  end

  def create
    user_id = vendor_profile_create_params[:user_id]
    user = User.find_by(id: user_id)

    unless user
      render json: { success: false, message: "User not found" }, status: :not_found
      return
    end

    existing_profile = VendorProfile.find_by(user_id: user_id)
    if existing_profile
      render json: { success: false, message: "Profile already exists" }, status: :unprocessable_entity
      return
    end

    @vendor_profile = VendorProfile.new(basic_create_fields)

    # Attach profile image
    attach_profile_image_on_create

    # Process portfolios
    unless process_portfolios_on_create
      render json: { success: false, errors: [ "At least one portfolio is required" ] }, status: :unprocessable_entity
      return
    end

    if @vendor_profile.save
      render json: {
        success: true,
        message: "Vendor profile created successfully",
        data: VendorSerilizers::VendorProfileShowSerializer.new(@vendor_profile).serializable_hash
      }, status: :created
    else
      render json: {
        success: false,
        errors: @vendor_profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error "Vendor profile create error: #{e.message}"
    render json: { success: false, errors: [ e.message ] }, status: :internal_server_error
  end

  # private


  def basic_create_fields
    vendor_profile_create_params.slice(
      :full_name,
      :phone_number,
      :second_phone_number,
      :address,
      :latitude,
      :longitude,
      :user_id
    )
  end

  def attach_profile_image_on_create
    return unless vendor_profile_create_params[:profile_image].present?

    @vendor_profile.profile_image.attach(vendor_profile_create_params[:profile_image])
  end

  def process_portfolios_on_create
    portfolios_params = vendor_profile_create_params[:vendor_portfolios_attributes]
    return false if portfolios_params.blank?

    portfolios_data = portfolios_params.to_h.values
    return false if portfolios_data.empty?

    portfolios_data.each do |pdata|
      portfolio = @vendor_profile.vendor_portfolios.build(work_experience: pdata[:work_experience])

      # Attach images
      images = Array(pdata[:work_images]).reject(&:blank?)
      images.each { |img| portfolio.images.attach(img) }
    end

    true
  end

  def update
    @vendor_profile = VendorProfile.find(params[:id])

    update_profile

    if @vendor_profile.save
      render json: {
        message: "Updated successfully",
        data: VendorSerilizers::VendorProfileUpdateSerializer.new(@vendor_profile.reload).as_json
      }, status: :ok
    else
      render json: {
        message: "Failed",
        errors: @vendor_profile.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { message: "Profile not found" }, status: :not_found
  rescue => e
    Rails.logger.error "Vendor profile update error: #{e.message}\n#{e.backtrace.first(5).join("\n")}"
    render json: { message: "Error", errors: [ e.message ] }, status: :internal_server_error
  end

  private

  def vendor_profile_update_params
    @vendor_profile_update_params ||= params.require(:vendor_profile).permit(
      :full_name,
      :phone_number,
      :second_phone_number,
      :address,
      :latitude,
      :longitude,
      :user_id,
      :profile_image,
      vendor_portfolios_attributes: [
        :id,
        :work_experience,
        { work_images: [] },
        { keep_image_ids: [] }
      ]
    )
  end

  def update_profile
    # Update basic fields
    @vendor_profile.assign_attributes(basic_fields)

    # Update profile image
    attach_profile_image if vendor_profile_update_params[:profile_image].present?

    # Update portfolios
    process_portfolios if vendor_profile_update_params[:vendor_portfolios_attributes].present?
  end

  def basic_fields
    vendor_profile_update_params.slice(
      :full_name,
      :phone_number,
      :second_phone_number,
      :address,
      :latitude,
      :longitude
    )
  end

  def attach_profile_image
    @vendor_profile.profile_image.purge if @vendor_profile.profile_image.attached?
    @vendor_profile.profile_image.attach(vendor_profile_update_params[:profile_image])
  end

  def process_portfolios
    portfolios_data = vendor_profile_update_params[:vendor_portfolios_attributes].to_h.values
    kept_ids = []

    portfolios_data.each do |pdata|
      portfolio = find_or_build_portfolio(pdata[:id]&.to_i)
      next unless portfolio

      update_portfolio(portfolio, pdata)
      kept_ids << portfolio.id
    end

    # Remove deleted portfolios
    @vendor_profile.vendor_portfolios.where.not(id: kept_ids).destroy_all
  end

  def find_or_build_portfolio(portfolio_id)
    if portfolio_id.present? && portfolio_id > 0
      @vendor_profile.vendor_portfolios.find_by(id: portfolio_id)
    else
      @vendor_profile.vendor_portfolios.build
    end
  end

  def update_portfolio(portfolio, pdata)
    portfolio.work_experience = pdata[:work_experience]

    # Handle images
    keep_ids = Array(pdata[:keep_image_ids]).map(&:to_i).reject(&:zero?)
    new_images = Array(pdata[:work_images]).reject(&:blank?)

    # Remove images not in keep list (only for existing portfolios)
    if portfolio.persisted?
      portfolio.images.each { |img| img.purge unless keep_ids.include?(img.id) }
    end

    # Add new images
    new_images.each { |img| portfolio.images.attach(img) }

    portfolio.save!
  end

  def vendor_profile_create_params
    @vendor_profile_create_params ||= params.require(:vendor_profile).permit(
      :full_name,
      :phone_number,
      :second_phone_number,
      :address,
      :latitude,
      :longitude,
      :user_id,
      :profile_image,
      vendor_portfolios_attributes: [
        :work_experience,
        { work_images: [] },
        { keep_image_ids: [] }
      ]
    )
  end

  # def vendor_profile_params
  #   params.require(:vendor_profile).permit(
  #     :full_name,
  #     :phone_number,
  #     :second_phone_number,
  #     :address,
  #     :latitude,
  #     :longitude,
  #     :user_id,
  #     :profile_image,
  #     vendor_portfolios_attributes: [
  #       :work_experience,
  #       { work_images: [] },
  #       { keep_image_ids: [] }
  #     ]
  #   )
  # end

  # def vendor_profile_update_params
  #   params.require(:vendor_profile).permit(
  #     :full_name,
  #     :phone_number,
  #     :second_phone_number,
  #     :address,
  #     :latitude,
  #     :longitude,
  #     :user_id,
  #     :profile_image,
  #     vendor_portfolios_attributes: [
  #       :id,  # Important: Allow id for updates
  #       :work_experience,
  #       { work_images: [] },
  #       { keep_image_ids: [] }
  #     ]
  #   )
  # end



  # def vendor_params
  #   params.require(:vendor_profile).permit(:user_id, :full_name, :address, :latitude, :longitude, :phone_number, :second_phone_number, :profile_image, :cnic_front, :cnic_back)
  # end
end
