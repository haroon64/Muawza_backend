require "test_helper"

class Api::V1::Customer::CustomerProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_customer_customer_profiles_index_url
    assert_response :success
  end

  test "should get show" do
    get api_v1_customer_customer_profiles_show_url
    assert_response :success
  end

  test "should get create" do
    get api_v1_customer_customer_profiles_create_url
    assert_response :success
  end

  test "should get update" do
    get api_v1_customer_customer_profiles_update_url
    assert_response :success
  end

  test "should get destroy" do
    get api_v1_customer_customer_profiles_destroy_url
    assert_response :success
  end
end
