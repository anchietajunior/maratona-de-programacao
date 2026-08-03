require "test_helper"

class ProblemTest < ActiveSupport::TestCase
  test "the difficulty decides the points" do
    assert_equal 10, problems(:easy_sum).points
    assert_equal 20, problems(:medium_primes).points
    assert_equal 30, problems(:hard_fibonacci).points
  end

  test "a difficulty outside the three levels is invalid" do
    problem = problems(:easy_sum)
    problem.difficulty = "impossible"

    assert_not problem.valid?
  end

  test "the url carries the position, not the id" do
    assert_equal "1", problems(:easy_sum).to_param
  end

  test "two problems cannot share a position in the same contest" do
    assert_not problems(:easy_sum).dup.valid?
  end

  test "problems are read in the order of the competition" do
    assert_equal [ 1, 2, 3 ], contests(:maratona).problems.ordered.map(&:position)
  end
end
