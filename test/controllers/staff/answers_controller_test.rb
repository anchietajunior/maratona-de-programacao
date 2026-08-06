require "test_helper"

class Staff::AnswersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "the committee answers a pending clarification" do
    assert_difference -> { Answer.count }, +1 do
      post staff_clarification_answer_path(clarifications(:lovelace_hard)),
        params: { answer: { body: "Conta sim.", collective: "1" } }
    end

    answer = clarifications(:lovelace_hard).reload.answer
    assert_equal users(:technical_committee), answer.user
    assert answer.collective?
    assert_redirected_to staff_clarifications_path
  end

  test "answering twice is refused instead of blowing up" do
    assert_no_difference -> { Answer.count } do
      post staff_clarification_answer_path(clarifications(:turing_easy)),
        params: { answer: { body: "De novo." } }
    end

    assert_redirected_to staff_clarifications_path
  end

  test "a team cannot answer" do
    sign_out
    sign_in_as users(:turing)

    post staff_clarification_answer_path(clarifications(:lovelace_hard)),
      params: { answer: { body: "Pode isso?" } }

    assert_response :forbidden
  end
end
