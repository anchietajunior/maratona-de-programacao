require "test_helper"

# Docker de verdade: a saída esperada só existe porque a Solução de Referência rodou.
class Testcase::GeneratedTest < ActiveSupport::TestCase
  test "the expected output is what the reference solution prints" do
    testcase = problems(:easy_sum).testcases.create! input: "2 3\n"

    assert_equal "5\n", testcase.expected_output
  end

  test "an input the reference solution cannot handle is refused" do
    testcase = problems(:easy_sum).testcases.new input: "não é número\n"

    assert_not testcase.valid?
    assert_includes testcase.errors.full_messages.to_sentence, "RE"
  end

  # O formulário devolve CRLF; um \r gravado faria input() e input().strip() divergirem.
  test "the CRLF the browser sends is stored as plain line breaks" do
    testcase = problems(:easy_sum).testcases.create! input: "2 3\r\n"

    assert_equal "2 3\n", testcase.input
    assert_equal "5\n", testcase.expected_output
  end

  # A saída esperada nunca vem do formulário, mesmo que alguém a mande (ADR-0003).
  test "an expected output sent from outside is overwritten by the generated one" do
    testcase = problems(:easy_sum).testcases.create! input: "2 3\n", expected_output: "99\n"

    assert_equal "5\n", testcase.expected_output
  end
end
