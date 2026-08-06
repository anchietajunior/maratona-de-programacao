require "test_helper"

class Staff::SessionsControllerTest < ActionDispatch::IntegrationTest
  # Quando a máquina da Equipe trava, é a Comissão que a destranca (ADR-0009).
  test "ending a team session frees its login again" do
    session = users(:turing).sessions.create!
    sign_in_as users(:technical_committee)

    assert users(:turing).signed_in_elsewhere?

    delete staff_session_path(session)

    assert_not users(:turing).reload.signed_in_elsewhere?
    assert_redirected_to staff_root_path
  end

  test "a team cannot end another team's session" do
    session = users(:hopper).sessions.create!
    sign_in_as users(:turing)

    delete staff_session_path(session)

    assert_response :forbidden
  end
end
