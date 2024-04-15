require "test_helper"

class Admin::JudgingTeamsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_judging_teams_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_judging_teams_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_judging_teams_update_url
    assert_response :success
  end
end
