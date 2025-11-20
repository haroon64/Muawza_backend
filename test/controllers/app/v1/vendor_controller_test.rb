require "test_helper"

class App::V1::VendorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get app_v1_vendor_index_url
    assert_response :success
  end

  test "should get show" do
    get app_v1_vendor_show_url
    assert_response :success
  end

  test "should get create" do
    get app_v1_vendor_create_url
    assert_response :success
  end
end
