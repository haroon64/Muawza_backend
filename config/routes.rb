Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Only use RESTful resource routing for customer_profiles; remove explicit custom GETs
      namespace :customer do
        resources :customer_profiles, only: [:index, :show, :create, :update, :destroy]
      end
      namespace :vendor do
        resources :vendor_profiles,only: [:index, :show, :create, :update, :destroy]
      end

      # Devise routes
      devise_for :users,
        path: '',
        path_names: {
          sign_in: 'signin',
          sign_out: 'signout',
          registration: 'signup'
        },
        controllers: {
          sessions: 'api/v1/users/auth/sessions',
          registrations: 'api/v1/users/auth/registrations',
          passwords: 'api/v1/users/auth/passwords',
          omniauth_callbacks: 'api/v1/users/auth/omniauth_callbacks'
        },
        defaults: { format: :json }

      # Services routess
      namespace :services do
        resources :service_icons, only: [:index, :show, :create, :update, :destroy]
        resources :sub_services, only: [:index, :show, :create, :update, :destroy]
        get 'sub_services_by_service/:id', to: 'sub_services#sub_services_by_service'
        get 'sub_services/search_by_city/:city', to: 'sub_services#search_by_city'
      end
      # Do not nest duplicate namespace :customer, only declare resources once
    end
  end
end