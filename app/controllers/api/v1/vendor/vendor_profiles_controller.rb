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

  def create
    user_id = vendor_profile_params[:user_id]
    user = User.find(user_id)

    existing_profile = VendorProfile.find_by(user_id: user_id)
    if existing_profile
      render json: { success: false, message: "Profile already exists" }, status: :unprocessable_entity
      return
    end
    profile = VendorProfile.new(vendor_profile_params.except(:profile_image, :vendor_portfolios))
    profile.profile_image.attach(vendor_profile_params[:profile_image]) if vendor_profile_params[:profile_image].present?
    portfolios_params = vendor_profile_params[:vendor_portfolios] || []
    if portfolios_params.empty?
      return render json: { success: false, errors: ["At least one portfolio is required"] }, status: :unprocessable_entity
    end
    portfolios = []
    portfolio_errors = []
    portfolios_params.each_value do |portfolio_param|
      portfolio = profile.vendor_portfolios.build(
        work_experience: portfolio_param[:work_experience]
      )
      unless portfolio.valid?
        portfolio_errors << "Portfolio credentials missing"
      end
      portfolios << { portfolio: portfolio, work_images: portfolio_param[:work_images] }
    end

    # Check the vendor profile itself and portfolio credentials together
    if profile.valid? && portfolio_errors.empty?
      ActiveRecord::Base.transaction do
        profile.save!
        # Now save portfolios and attach images
        portfolios.each do |entry|
          portfolio = entry[:portfolio]
          portfolio.vendor_profile_id = profile.id
          portfolio.save!
          if entry[:work_images].present?
            entry[:work_images].each { |img| portfolio.images.attach(img) }
          end
        end

        render json: VendorSerilizers::VendorProfileShowSerializer.new(profile).serializable_hash, status: :created
      end
    else
      errors = profile.errors.full_messages + portfolio_errors
      render json: { success: false, errors: errors }, status: :unprocessable_entity
    end
  end
 
  
  def update
    puts "-----------update"
    vendor_profile = VendorProfile.find(params[:id])
        puts "-----------update-1"
    # Update basic vendor profile attributes (excluding portfolios and image)
    vendor_profile.assign_attributes(vendor_profile_params.except(:profile_image, :vendor_portfolios))
       puts "-----------update-2"

    # Handle profile image update if provided
    if vendor_profile_params[:profile_image].present?
      vendor_profile.profile_image.attach(vendor_profile_params[:profile_image])
         puts "-----------update-3"
    end
       puts "-----------update-4"

    portfolios_params = vendor_profile_params[:vendor_portfolios] || {}
   puts "-----------update-5"
    # Update portfolios if present in the params
    unless portfolios_params.empty?
      
      # Accept either Hash with string keys or Array
      # Remove all current portfolios and replace with new ones for simplicity
      vendor_profile.vendor_portfolios.destroy_all
puts "-----------update-6"
      portfolios_params.each_value do |portfolio_param|
        portfolio = vendor_profile.vendor_portfolios.build(
          work_experience: portfolio_param[:work_experience]
        )
        puts "-----------update-7"
        # Attach new images if provided
        if portfolio_param[:work_images].present?
          portfolio_param[:work_images].each { |img| portfolio.images.attach(img) }
        end
      end
    end

    if vendor_profile.save
      render json: {
        message: "Vendor profile updated successfully",
        data: VendorSerilizers::VendorProfileShowSerializer.new(vendor_profile).serializable_hash
      }, status: :ok
    else
      errors = vendor_profile.errors.full_messages
      render json: {
        message: "Failed to update vendor profile",
        errors: errors
      }, status: :unprocessable_entity
    end
  end
  

  def destroy
    @vendor.destroy
    head :no_content
  end

  private

  def set_vendor
    @vendor = VendorProfile.find_by(id: params[:id])
  end

   
def vendor_profile_params
  params.require(:vendor_profile).permit(
    :full_name,
    :phone_number,
    :second_phone_number,
    :address,
    :latitude,
    :longitude,
    :user_id,
    :profile_image,
    vendor_portfolios: [
      :work_experience,
      { work_images: [] }
    ]
  )
end


  def vendor_params
    params.require(:vendor_profile).permit(:user_id, :full_name, :address, :latitude, :longitude, :phone_number, :second_phone_number, :profile_image, :cnic_front, :cnic_back)
  end
end


 