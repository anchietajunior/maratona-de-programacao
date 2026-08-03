require "test_helper"

# A matriz dos sete veredictos vive em test/judge_test.rb, contra o Juiz. Aqui o que
# importa é a ponte: a Submissão entra na fila sozinha e o veredicto chega na coluna.
class Submission::JudgeableTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "a new submission enqueues its own judging" do
    assert_enqueued_with job: Submission::JudgeJob do
      problems(:easy_sum).submissions.create! \
        user: users(:hopper), code: problems(:easy_sum).reference_solution
    end
  end

  test "the job records the verdict of a correct solution" do
    submission = submissions(:dijkstra_pending)

    assert_changes -> { submission.reload.verdict }, from: nil, to: "AC" do
      perform_enqueued_jobs { Submission::JudgeJob.perform_later submission }
    end
  end

  test "a wrong solution records WA" do
    submission = submissions(:dijkstra_pending)
    submission.update! code: "a, b = map(int, input().split())\nprint(a - b)\n"

    submission.judge_now

    assert_equal "WA", submission.reload.verdict
  end

  # A saída esperada vem de coluna binária: sem comparação por bytes, todo Problema com
  # acento na saída daria WA (ADR-0003).
  test "an accented expected output is judged by its bytes" do
    problem = problems(:easy_sum)
    problem.testcases.destroy_all
    problem.testcases.create! input: "1\n", expected_output: "não\n"
    submission = problem.submissions.create! user: users(:hopper), code: %(input()\nprint("não")\n)

    submission.judge_now

    assert_equal "AC", submission.reload.verdict
  end
end
