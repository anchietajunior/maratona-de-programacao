require "test_helper"

class ClarificationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:turing) }

  test "a team sees its own questions and the collective announcements" do
    get clarifications_path

    assert_response :success
    assert_select "li", text: /números negativos/
  end

  # O que é coletivo é o assunto; a pergunta particular de outra Equipe não é (Art. 34).
  test "another team's private question is nowhere on the page" do
    get clarifications_path

    assert_response :success
    assert_select "li", { text: /F\(0\) conta como termo/, count: 0 }
  end

  test "a team asks about a problem" do
    assert_difference -> { users(:turing).clarifications.count }, +1 do
      post problem_clarifications_path(problems(:medium_primes)),
        params: { clarification: { question: "A entrada tem limite superior?" } }
    end

    assert_redirected_to clarifications_path
  end

  test "asking is refused after the competition ends" do
    contests(:maratona).finish

    assert_no_difference -> { Clarification.count } do
      post problem_clarifications_path(problems(:medium_primes)),
        params: { clarification: { question: "Ainda dá tempo?" } }
    end
  end
end
