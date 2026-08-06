require "test_helper"

class StandingsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:turing) }

  # A Classificação é apurada ao término e divulgada só na premiação (Art. 28).
  test "the standings are out of reach for a team until they are published" do
    get standings_path

    assert_redirected_to scoreboard_path
  end

  test "after publication the team sees the standings" do
    contests(:maratona).publish

    get standings_path

    assert_response :success
    assert_select "td", text: "Hopper"
  end
end
