require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:turing) }

  test "a team submits code for a problem" do
    assert_difference -> { problems(:medium_primes).submissions.count }, +1 do
      post problem_submissions_path(problems(:medium_primes)), params: { submission: { code: "print(1)\n" } }
    end

    assert_redirected_to problem_path(problems(:medium_primes))
    assert_equal users(:turing), Submission.order(:created_at).last.user
  end

  test "a submission is refused after the competition ends" do
    contests(:maratona).finish

    assert_no_difference -> { Submission.count } do
      post problem_submissions_path(problems(:easy_sum)), params: { submission: { code: "print(1)\n" } }
    end

    assert_redirected_to problem_path(problems(:easy_sum))
  end

  test "submitting requires authentication" do
    sign_out

    post problem_submissions_path(problems(:easy_sum)), params: { submission: { code: "print(1)\n" } }

    assert_redirected_to new_session_path
  end
end
