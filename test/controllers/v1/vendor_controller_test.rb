require "test_helper"

class V1::VendorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get v1_vendor_index_url
    assert_response :success
  end

  test "should get show" do
    get v1_vendor_show_url
    assert_response :success
  end

  test "should get create" do
    get v1_vendor_create_url
    assert_response :success
  end
end
