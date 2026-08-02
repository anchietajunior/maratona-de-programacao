# rbs_inline: enabled

require "test_helper"

class JudgeTest < ActiveSupport::TestCase
  PALINDROME = [
    { input: "RADAR\n",      expected: "SIM\n" },
    { input: "cachorro\n",   expected: "NAO\n" },
    { input: "under_line\n", expected: "NAO\n" }
  ].freeze

  CORRECT = <<~PY
    s = input().strip()
    print("SIM" if s == s[::-1] else "NAO")
  PY

  setup { @judge = Judge.new(time_limit: 3) }

  # --- Output comparison (no Docker, runs in milliseconds) ---

  test "identical output is AC" do
    assert_equal "AC", compare("SIM\n", "SIM\n")
  end

  test "whitespace-only difference is PE, not WA" do
    assert_equal "PE", compare("SIM \n", "SIM\n")
    assert_equal "PE", compare("SIM\n\n", "SIM\n")
    assert_equal "PE", compare("SIM", "SIM\n")
  end

  test "different case is WA" do
    # MySQL disagrees: under utf8mb4_0900_ai_ci, "SIM" = "sim" is true. See ADR-0003.
    assert_equal "WA", compare("Sim\n", "SIM\n")
  end

  test "wrong answer is WA" do
    assert_equal "WA", compare("NAO\n", "SIM\n")
  end

  test "multiline output" do
    assert_equal "AC", compare("A\nB\n", "A\nB\n")
    assert_equal "WA", compare("A\nC\n", "A\nB\n")
  end

  # --- Real judging in a container ---

  test "correct solution gets AC" do
    assert_equal "AC", judge(CORRECT).verdict
  end

  test "wrong algorithm gets WA and reports the failing case" do
    result = judge(%{print("SIM")\n})
    assert_equal "WA", result.verdict
    assert_equal 2, result.failed_case
  end

  test "bad formatting gets PE" do
    assert_equal "PE", judge(<<~PY).verdict
      s = input().strip()
      print(("SIM" if s == s[::-1] else "NAO") + " ")
    PY
  end

  test "syntax error gets CE without running any case" do
    assert_equal "CE", judge(%{print("SIM"\n}).verdict
  end

  test "infinite loop gets TLE" do
    assert_equal "TLE", judge("while True: pass\n").verdict
  end

  test "runtime exception gets RE" do
    assert_equal "RE", judge("raise ValueError('boom')\n").verdict
  end

  test "memory exhaustion gets MLE" do
    strict = Judge.new(time_limit: 10, memory: "128m")
    result = strict.judge("x = bytearray(500 * 1024 * 1024)\n", [ { input: "\n", expected: "ok\n" } ])
    assert_equal "MLE", result.verdict
  end

  # --- Isolation: what submitted code must not be able to do ---

  test "cannot reach the network" do
    assert_equal "RE", judge(<<~PY).verdict
      import urllib.request
      urllib.request.urlopen("https://example.com", timeout=2)
    PY
  end

  test "cannot write to its own source file" do
    assert_equal "RE", judge(%{open("/code/solution.py", "w").write("x")\n}).verdict
  end

  test "stops at the first failing case" do
    assert_equal 1, judge("s = input().strip()\nprint('NAO')\n").failed_case
  end

  private

  # Reaches into the private comparison, which is the logic that decides scoring.
  #: (String, String) -> String
  def compare(actual, expected) = @judge.send(:compare, actual, expected)

  #: (String, ?Array[Hash[Symbol, String]]) -> Judge::Result
  def judge(code, cases = PALINDROME) = @judge.judge(code, cases)
end
