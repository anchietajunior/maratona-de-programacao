require "test_helper"

class Problem::VerifiableTest < ActiveSupport::TestCase
  test "a reference solution that fails the existing testcases is refused" do
    problem = problems(:easy_sum)
    problem.reference_solution = "a, b = map(int, input().split())\nprint(a - b)\n"

    assert_not problem.valid?
    assert_includes problem.errors.full_messages.to_sentence, "casos de teste"
  end

  test "a reference solution that still passes is accepted" do
    problem = problems(:easy_sum)
    problem.reference_solution = "print(sum(map(int, input().split())))\n"

    assert problem.valid?
  end

  test "a problem without testcases has nothing to check yet" do
    problem = problems(:easy_sum)
    problem.testcases.destroy_all
    problem.reference_solution = "print('qualquer coisa')\n"

    assert problem.valid?
  end

  test "editing anything but the reference solution starts no container" do
    problem = problems(:easy_sum)
    problem.title = "Outro título"

    assert problem.valid?
  end
end
