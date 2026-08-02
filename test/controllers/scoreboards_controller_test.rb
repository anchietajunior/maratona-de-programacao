require "test_helper"

class ScoreboardsControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get scoreboard_path

    assert_redirected_to new_session_path
  end

  test "a team sees its own scoreboard" do
    sign_in_as users(:turing)

    get scoreboard_path

    assert_response :success
    assert_select "h1", "Placar Individual"
  end
end
