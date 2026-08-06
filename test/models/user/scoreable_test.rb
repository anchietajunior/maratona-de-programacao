require "test_helper"

# As regras de pontuação são o produto. O mundo dos fixtures já conta a história: turing
# errou e depois acertou o fácil, lovelace errou um difícil que nunca resolveu.
class User::ScoreableTest < ActiveSupport::TestCase
  test "only an accepted submission scores, and it scores the full difficulty" do
    assert_equal 10, users(:turing).score
    assert_equal 20, users(:hopper).score
  end

  test "a problem with attempts but no AC scores nothing" do
    assert_equal 0, users(:lovelace).score
  end

  test "the accumulated time is the minutes until the AC plus the penalty before it" do
    assert_equal 22, users(:turing).total_time
  end

  test "an AC of first try carries no penalty" do
    assert_equal 25, users(:hopper).total_time
  end

  test "a wrong attempt on a problem never solved costs nothing" do
    assert_equal 0, users(:lovelace).total_time
  end

  # O Art. 27 permite submeter depois do AC. Nada do que vem depois pode mexer no placar.
  test "a wrong attempt after the AC neither penalizes nor unsolves the problem" do
    team = users(:turing)
    team.submissions.create! problem: problems(:easy_sum), code: "print(0)\n", verdict: "WA"

    assert_equal 10, team.reload.score
    assert_equal 22, team.total_time
  end

  test "a second AC on the same problem does not score twice" do
    team = users(:turing)
    team.submissions.create! problem: problems(:easy_sum), code: "print(1)\n", verdict: "AC"

    assert_equal 10, team.reload.score
    assert_equal 22, team.total_time
  end

  test "a submission still waiting for the judge does not penalize" do
    assert_equal 0, users(:dijkstra).total_time
  end

  test "the standings lead with the highest score" do
    assert_equal users(:hopper), User.standings.first
  end

  test "a tie in score is broken by the smaller accumulated time" do
    users(:lovelace).submissions.create! \
      problem: problems(:medium_primes), code: "x\n", verdict: "AC", created_at: 30.minutes.ago

    assert_equal [ users(:lovelace), users(:hopper) ], User.standings.first(2)
  end

  # Mesma Pontuação e mesmo Tempo Acumulado: decide quem resolveu o Problema mais difícil.
  test "a tie in score and time is broken by the hardest problem solved" do
    users(:dijkstra).submissions.create! \
      problem: problems(:hard_fibonacci), code: "x\n", verdict: "AC", created_at: 30.minutes.ago
    users(:lovelace).submissions.create! \
      problem: problems(:easy_sum), code: "x\n", verdict: "AC", created_at: 36.minutes.ago
    users(:lovelace).submissions.create! \
      problem: problems(:medium_primes), code: "x\n", verdict: "AC", created_at: 34.minutes.ago

    assert_equal 30, users(:dijkstra).reload.score
    assert_equal 30, users(:lovelace).reload.score
    assert_equal users(:dijkstra).total_time, users(:lovelace).total_time
    assert_equal [ users(:dijkstra), users(:lovelace) ], User.standings.first(2)
  end

  test "the standings never carry staff" do
    assert_not_includes User.standings, users(:technical_committee)
  end

  test "a team knows which problems it solved" do
    assert_equal [ problems(:easy_sum) ], users(:turing).solved_problems
    assert users(:turing).solved?(problems(:easy_sum))
    assert_not users(:turing).solved?(problems(:medium_primes))
  end

  test "attempts count every submission on the problem, judged or not" do
    assert_equal 2, users(:turing).attempts_on(problems(:easy_sum))
    assert_equal 1, users(:dijkstra).attempts_on(problems(:easy_sum))
  end
end
