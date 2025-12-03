class Api::V1::Users::UsersController < ApplicationController
  before_action :set_user

  def update_role
    if @user.update(role: params[:role])
      render json: { status: "success", message: "Role updated successfully", user: @user }
    else
      render json: { status: "error", message: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
