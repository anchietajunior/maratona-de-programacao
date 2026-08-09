require "test_helper"

class ProblemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:turing) }

  test "index lists every problem with its difficulty" do
    get problems_path

    assert_response :success
    assert_select "h2", text: "Soma de dois números"
    assert_select "li", text: /Difícil/
  end

  # A Equipe está com pressa: o cartão inteiro abre o Problema, não só o título.
  test "the whole card of a problem is the link to it" do
    get problems_path

    assert_select "li a[href=?]", problem_path(problems(:medium_primes)), text: /Médio/
  end

  test "show renders the statement as markdown" do
    get problem_path(problems(:easy_sum))

    assert_response :success
    assert_select "h1", "Soma de dois números"
    assert_select ".statement h2", text: "Entrada"
  end

  test "a problem is reached by its position, not by its id" do
    get problem_path(problems(:medium_primes))

    assert_response :success
    assert_select "h1", "Contagem de primos"
  end

  test "the problems are out of reach before the competition starts" do
    contests(:maratona).update! started_at: nil

    get problems_path

    assert_redirected_to scoreboard_path
  end

  test "the submit form disappears once the competition ends" do
    contests(:maratona).finish

    get problem_path(problems(:easy_sum))

    assert_response :success
    assert_select "textarea[name=?]", "submission[code]", count: 0
  end
end
