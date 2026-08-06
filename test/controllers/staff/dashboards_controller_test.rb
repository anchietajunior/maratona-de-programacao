require "test_helper"

class Staff::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "show requires authentication" do
    get staff_root_path

    assert_redirected_to new_session_path
  end

  test "a team is forbidden from the staff surface" do
    sign_in_as users(:turing)

    get staff_root_path

    assert_response :forbidden
  end

  test "staff sees the competing teams" do
    sign_in_as users(:technical_committee)

    get staff_root_path

    assert_response :success
    assert_select "li", text: /Turing/
    assert_select "li", text: /Hopper/
    assert_select "li", { text: /Comissão Técnica/, count: 0 }
  end

  test "the restart button only shows once there is a round to reset" do
    sign_in_as users(:technical_committee)

    get staff_root_path
    assert_select "button", text: "Reiniciar competição"

    contests(:maratona).update! started_at: nil
    get staff_root_path
    assert_select "button", { text: "Reiniciar competição", count: 0 }
  end
end
