Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      patch "users/:id/update_role", to: "users/users#update_role"
    end
  end

  namespace :api do
    namespace :v1 do
      namespace :customer do
        resources :customer_profiles, only: [ :index, :show, :create, :update, :destroy ]
      end
      namespace :vendor do
        resources :vendor_profiles, only: [ :index, :show, :create, :update, :destroy ]
         get "vendor_by_id/:id", to: "vendor_profiles#vendor_by_id"
      end

      # Devise routes
      devise_for :users,
        path: "",
        path_names: {
          sign_in: "signin",
          sign_out: "signout",
          registration: "signup"
        },
        controllers: {
          sessions: "api/v1/users/auth/sessions",
          registrations: "api/v1/users/auth/registrations",
          passwords: "api/v1/users/auth/passwords",
          omniauth_callbacks: "api/v1/users/auth/omniauth_callbacks"
        },
        defaults: { format: :json }
        namespace :conversations do
          resources :conversations, only: [ :show, :create, :update, :destroy ]
          resources :messages, only: [  :show, :create, :update, :destroy ]
        end

      namespace :services do
        resources :service_icons, only: [ :index, :show, :create, :update, :destroy ]
        resources :sub_services, only: [ :index, :show, :create, :update, :destroy ]
        resources :categories, only: [ :show ]
        get "sub_services_by_service/:id", to: "sub_services#sub_services_by_service"
        get "sub_services_by_vendor/:id", to: "sub_services#sub_services_by_vendor"
        get "sub_services/search_by_city/:city", to: "sub_services#search_by_city"
        get "sub_services_by_vendor_id/:id", to: "sub_services#sub_services_by_vendor_id"
        delete "delete_by_sub_service_id/:id", to: "sub_services#delete_by_sub_service_id"
      end
    end
  end
end
