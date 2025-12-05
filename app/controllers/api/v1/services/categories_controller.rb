# The line appears to be correct if your intention is to define a controller named
# `Api::V1::Services::CategoriesController`, which matches Rails conventions based on
# your usage of `resources :categories` (plural) elsewhere. The filename
# should also be `categories_controller.rb` (plural) to match this.
class Api::V1::Services::CategoriesController < ApplicationController
  def show
    service_id = params[:id]
    if service_id.present?
      categories = Category.where(service_id: service_id)
      render json: categories, status: :ok
    else
      render json: { error: "service_id param is required" }, status: :bad_request
    end
  end
end
