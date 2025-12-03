class Api::V1::Customer::CustomerProfilesController < ApplicationController
  include ApiAuthentication
  before_action  :set_default_format
  # GET /api/v1/customer/customer_profiles
  def index
    profiles = CustomerProfile.all
    render json: profiles, each_serializer: CustomerProfileShowSerializer, status: :ok
  end

  # GET /api/v1/customer/customer_profiles/:id
  def show
    profile = CustomerProfile.find_by(user_id: params[:id])

    if profile
      render json: { exists: true, profile: CustomerSerilizers::CustomerProfileShowSerializer.new(profile).as_json }, status: :ok
    else
      render json: { exists: false, message: "Profile not found" }, status: :not_found
    end
  end

  def create
    required_fields = [:user_id, :full_name, :phone_number, :gender, :address, :latitude, :longitude]
    missing_fields = required_fields.select { |key| customer_profile_params[key].blank? }
    if missing_fields.any?
      return render json: { success: false, message: "Missing or blank parameter(s): #{missing_fields.join(', ')}" }, status: :bad_request
    end

    user_id = customer_profile_params[:user_id].to_i

    existing_profile = CustomerProfile.find_by(user_id: user_id)
    if existing_profile
      return render json: { success: false, message: "Profile already exists" }, status: :unprocessable_entity
    end

    begin
      user = User.find(user_id)
      profile = CustomerProfile.new(customer_profile_params.except(:profile_image))
      # attach image
      if customer_profile_params[:profile_image].present?
        profile.profile_image.attach(customer_profile_params[:profile_image])
      end

      if profile.save
        render json: CustomerSerilizers::CreateCustomerProfileShowSerializer.new(profile).serializable_hash, status: :created
      else
        render json: { success: false, errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { success: false, message: "User not found" }, status: :not_found
    end
  end

  def update
    profile = CustomerProfile.find_by(user_id: params[:id])
    unless profile
      render json: { success: false, message: "Profile not found" }, status: :not_found and return
    end
    permitted_params = customer_profile_update_params
    # Handle profile_image separately if provided
    if permitted_params[:profile_image].present?
      profile.profile_image.attach(permitted_params[:profile_image])
    elsif permitted_params[:profile_image] == ""
      # Do nothing if the key is present but empty string (as per strong param logic)
    end
    # Remove :profile_image so we don't double assign it (since it's attached above)
    assignable_params = permitted_params.except(:profile_image)
    profile.assign_attributes(assignable_params)
    if profile.save
      render json: CustomerSerilizers::CreateCustomerProfileShowSerializer.new(profile).serializable_hash, status: :ok
    else
      render json: { success: false, errors: profile.errors.full_messages }, status: :unprocessable_entity
    end
  end
  # DELETE 
  def destroy
    profile = CustomerProfile.find_by(user_id: params[:id])
    unless profile
      render json: { success: false, message: "Profile not found" }, status: :not_found and return
    end

    profile.destroy
    render json: { success: true, message: "Profile deleted successfully" }
  end

  private

  def customer_profile_params
    permitted = params.require(:customer_profile).permit(
      :full_name,
      :user_id,      # frontend must send user_id
      :phone_number,
      :address,
      :latitude,
      :longitude,
      :gender,
      :profile_image # ActiveStorage file upload
    )
    # If profile_image param not present, set to empty string
    unless permitted.key?(:profile_image)
      permitted[:profile_image] = ""
    end
    permitted
  end

  def format_validation_errors(errors)
    errors.messages.map do |field, msgs|
      msgs.map { |msg| { field: field, error: msg } }
    end.flatten
  end

  def set_default_format
    request.format = :json
  end

 
  def customer_profile_update_params
    permitted = params.require(:customer_profile).permit(
      :full_name,
      :phone_number,
      :address,
      :latitude,
      :longitude,
      :gender,
      :profile_image # ActiveStorage file upload
    )
    # If profile_image param not present, set to empty string
    unless permitted.key?(:profile_image)
      permitted[:profile_image] = ""
    end
    permitted
  end
  
end

