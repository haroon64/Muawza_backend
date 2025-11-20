# app/serializers/customer_serializers/create_customer_profile_show_serializer.rb
module CustomerSerilizers
  class CreateCustomerProfileShowSerializer
    include JSONAPI::Serializer

    set_type :customer_profile

    # Only include the fields you want in the JSON response
    attributes :phone_number, :address, :latitude, :longitude, :user_id
  end
end
