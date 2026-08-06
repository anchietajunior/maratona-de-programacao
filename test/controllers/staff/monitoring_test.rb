require "test_helper"

# As telas de acompanhamento da Comissão: submissões com o código, fila de esclarecimentos
# e a Classificação, que a Comissão vê a qualquer momento.
class Staff::MonitoringTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "the committee reads the code each team submitted" do
    get staff_submissions_path

    assert_response :success
    assert_select "pre", text: /print\(a \+ b\)/
  end

  test "the clarification queue shows who asked and what is still open" do
    get staff_clarifications_path

    assert_response :success
    assert_select "li", text: /F\(0\) conta como termo/
    assert_select "textarea[name=?]", "answer[body]"
  end

  test "the committee reads the standings before any publication" do
    get staff_standings_path

    assert_response :success
    assert_not contests(:maratona).published?
    assert_select "td", text: "Hopper"
  end

  test "a team reaches none of it" do
    sign_out
    sign_in_as users(:turing)

    get staff_standings_path

    assert_response :forbidden
  end
end
