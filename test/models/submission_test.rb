require "test_helper"

class SubmissionTest < ActiveSupport::TestCase
  test "a submission without a verdict is still waiting for the judge" do
    assert_not submissions(:dijkstra_pending).judged?
    assert_not submissions(:dijkstra_pending).accepted?
  end

  test "only AC is accepted" do
    assert submissions(:turing_accepted).accepted?
    assert submissions(:turing_wrong).judged?
    assert_not submissions(:turing_wrong).accepted?
  end

  test "a verdict outside the seven is invalid" do
    submission = submissions(:turing_wrong)
    submission.verdict = "OK"

    assert_not submission.valid?
  end

  test "the accepted scope finds what a team solved" do
    assert_equal [ problems(:easy_sum) ], users(:turing).submissions.accepted.map(&:problem)
  end
end
