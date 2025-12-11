# app/controllers/api/v1/users/auth/sessions_controller.rb
class Api::V1::Users::Auth::SessionsController < Devise::SessionsController
  respond_to :json


  def create
    if sign_in_params[:user].nil?
      return render json: {
        status: { code: 400, message: "User parameters are required." }
      }, status: :bad_request
    end

    login_param = sign_in_params[:user][:email].presence || sign_in_params[:user][:phone_number].presence

    if login_param.blank? || sign_in_params[:user][:password].blank?
      return render json: {
        status: { code: 400, message: "Email/phone and password are required." }
      }, status: :bad_request
    end

    user = User.find_by(email: login_param) ||
           User.find_by(phone_number: login_param, role: role_param)

    if user&.valid_password?(sign_in_params[:user][:password])
      token = JwtService.encode(user_id: user.id)

      render json: {
        status: { code: 200, message: "Signed in successfully." },
        data: {
          user: {
            id: user.id,
            email: user.email,
            phone_number: user.phone_number,
            full_name: user.full_name,
            role: user.role
          },
          token: token
        }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "Invalid email/phone number or password." }
      }, status: :unauthorized
    end
  end

  def destroy
    token = request.headers["Authorization"]&.split(" ")&.last

    if token.present?
      render json: {
        status: { code: 200, message: "Signed out successfully." }
      }, status: :ok
    else
      render json: {
        status: { code: 401, message: "No token found or already signed out." }
      }, status: :unauthorized
    end
  end

  private

  def sign_in_params
    params.permit(user: [ :email, :phone_number, :password, :role ])
  end
end
