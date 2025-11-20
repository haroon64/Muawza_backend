class Api::V1::Vendor::VendorProfilesController < ApplicationController
  #  only: [:show, :update, :destroy]

  def index
    @vendors = VendorProfile.all
    render json: @vendors
  end

  def abc; end

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
      return render json: { success: false, message: "Profile already exists" }, status: :unprocessable_entity
    end
  
    # Build the VendorProfile object without images and portfolios
    profile = VendorProfile.new(vendor_profile_params.except(:profile_image, :vendor_portfolios))
    profile.user = user
    profile.full_name = user.full_name
  
    # Attach profile image if present
    profile.profile_image.attach(vendor_profile_params[:profile_image]) if vendor_profile_params[:profile_image].present?
  
    ActiveRecord::Base.transaction do
      if profile.save
        # Handle vendor portfolios
        if vendor_profile_params[:vendor_portfolios].present?
          # `each_value` because params are {"0"=>{…}, "1"=>{…}}
          vendor_profile_params[:vendor_portfolios].each_value do |portfolio_param|
            portfolio = profile.vendor_portfolios.build(
              work_experience: portfolio_param[:work_experience]
            )
  
            unless portfolio.save
              raise ActiveRecord::Rollback
            end
  
            # Attach multiple images for this portfolio
            portfolio_param[:work_images]&.each do |img|
              portfolio.images.attach(img)
            end
          end
        end
  
        render json: VendorSerilizers::VendorProfileShowSerializer.new(profile).serializable_hash, status: :created
      else
        render json: { success: false, errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end
  
  private
  
  def vendor_profile_params
    params.require(:vendor_profile).permit(
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
  
  
  def update
    if @vendor.update(vendor_params)
      render json: @vendor
    else
      render json: @vendor.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @vendor.destroy
    head :no_content
  end

  private

  def set_vendor
    @vendor = VendorProfile.find(params[:id])
  end

  def vendor_params
    params.require(:vendor_profile).permit(:user_id, :full_name, :address, :latitude, :longitude, :phone_number, :second_phone_number, :profile_image, :cnic_front, :cnic_back)
  end
end
