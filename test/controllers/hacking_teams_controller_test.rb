require "test_helper"

class HackingTeamsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get hacking_teams_index_url
    assert_response :success
  end
end
