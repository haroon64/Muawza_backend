class Api::V1::Customer::CustomerProfilesController < ApplicationController
  before_action  :set_default_format
  # GET /api/v1/customer/customer_profiles
  def index
    profiles = CustomerProfile.all
    render json: profiles, each_serializer: CustomerProfileShowSerializer, status: :ok
  end

  # GET /api/v1/customer/customer_profiles/:id
  def show
    puts "-------------------"
    profile = CustomerProfile.find_by(user_id: params[:id])
    puts "-------------------"
    puts "profile : #{profile}"
    if profile
      render json: { exists: true, profile: CustomerSerilizers::CustomerProfileShowSerializer.new(profile).as_json }, status: :ok
    else
      render json: { exists: false, message: "Profile not found" }, status: :not_found
    end
  end

  def create
    puts "inside customer create method -------------- "
    # puts "Userid-----#{user_id}"
    
  
    user_id = customer_profile_params[:user_id].to_i
    puts "Received params: #{params.inspect}"
    puts "Type of :user_id from frontend: #{customer_profile_params[:user_id].class}"
    puts "User exists? #{User.exists?(user_id)}"
    puts "User object: #{User.find_by(id: user_id).inspect}"
    puts "Profile image param class: #{customer_profile_params[:profile_image].class}"


    puts "inside customer create method --------------2 "
    existing_profile = CustomerProfile.find_by(user_id: user_id)
        puts "inside customer create method -------------3 "

    if existing_profile
      return render json: { success: false, message: "Profile already exists" }, status: :unprocessable_entity
    end
     puts "inside customer create method -------------4 "
  
    user = User.find(user_id)
    profile = CustomerProfile.new(customer_profile_params.except(:profile_image))
    profile.user = user
    profile.full_name = user.full_name
  
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
  # rescue StandardError => e
  #   render json: { success: false, message: "Internal server error: #{e.message}" }, status: :internal_server_error
  end
  
  private
  
  def customer_profile_params
    params.permit(:phone_number, :gender, :address, :latitude, :longitude, :user_id, :profile_image)
  end
  
  
  
  
  
  private
  
  def customer_profile_params
    params.permit(:phone_number, :gender, :address, :latitude, :longitude, :user_id,:profile_image)
  end
  

  # PUT/PATCH /api/v1/customer/customer_profiles/:id
  def update
    profile = CustomerProfile.find_by(user_id: params[:id])
    unless profile
      render json: { success: false, message: "Profile not found" }, status: :not_found and return
    end

    profile.assign_attributes(customer_profile_params)
    profile.full_name = profile.user.full_name  # always recalc

    if profile.valid?
      if profile.save
        render json: profile, serializer: CustomerProfileShowSerializer, status: :ok
      else
        render json: { success: false, errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { success: false, errors: format_validation_errors(profile.errors) }, status: :unprocessable_entity
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
      :user_id,      # frontend must send user_id
      :phone_number,
      :address,
      :latitude,
      :longitude,
      :gender,
      :profile_image        # ActiveStorage file upload
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
end
