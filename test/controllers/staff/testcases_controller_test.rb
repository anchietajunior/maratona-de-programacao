require "test_helper"

# Docker de verdade: a Comissão informa a entrada e a saída esperada nasce da execução.
class Staff::TestcasesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "the committee sends only the input and the expected output is generated" do
    assert_difference -> { problems(:easy_sum).testcases.count }, +1 do
      post staff_problem_testcases_path(problems(:easy_sum)), params: { testcase: { input: "7 8\n" } }
    end

    assert_equal "15\n", problems(:easy_sum).testcases.chronologically.last.expected_output
    assert_redirected_to staff_problem_path(problems(:easy_sum))
  end

  test "an input the reference solution cannot run creates nothing" do
    assert_no_difference -> { Testcase.count } do
      post staff_problem_testcases_path(problems(:easy_sum)), params: { testcase: { input: "nada disso\n" } }
    end

    assert_redirected_to staff_problem_path(problems(:easy_sum))
  end

  test "the committee deletes a testcase" do
    assert_difference -> { Testcase.count }, -1 do
      delete staff_problem_testcase_path(problems(:easy_sum), testcases(:sum_positives))
    end
  end

  test "a team is forbidden from registering testcases" do
    sign_out
    sign_in_as users(:turing)

    post staff_problem_testcases_path(problems(:easy_sum)), params: { testcase: { input: "1 1\n" } }

    assert_response :forbidden
  end
end
