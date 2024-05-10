require "test_helper"

class Admin::JudgingBreaksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get admin_judging_breaks_create_url
    assert_response :success
  end

  test "should get update" do
    get admin_judging_breaks_update_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_judging_breaks_destroy_url
    assert_response :success
  end
end
