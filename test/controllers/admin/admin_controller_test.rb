require "test_helper"

class Admin::AdminControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_admin_index_url
    assert_response :success
  end
end
