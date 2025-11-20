class Api::V1::Users::Auth::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    Rails.logger.info { "Signup params: #{request.filtered_parameters}" }
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?

    if resource.persisted?
      render json: {
        status: { code: 201, message: 'Signup successful.' },
        data: { user: resource }
      }, status: :created
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: {
        status: { code: 422, message: 'Signup failed.' },
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { message: 'Signup successful!', user: resource }, status: :ok
    else
      render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def sign_up_params
    params.require(:user).permit(
      :full_name,
      :email,
      :phone_number,
      :password,
      :password_confirmation,
      :role
    )
  end
end
