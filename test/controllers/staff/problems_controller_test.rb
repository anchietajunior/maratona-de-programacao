require "test_helper"

class Staff::ProblemsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:technical_committee) }

  test "a team is forbidden from the problem registration" do
    sign_out
    sign_in_as users(:turing)

    get staff_problems_path

    assert_response :forbidden
  end

  test "index lists the problems and how many testcases each one has" do
    get staff_problems_path

    assert_response :success
    assert_select "li", text: /2 casos de teste/
  end

  test "new renders the form" do
    get new_staff_problem_path

    assert_response :success
    assert_select "textarea[name=?]", "problem[reference_solution]"
  end

  # Toda Equipe precisa ver como capturar a entrada daquele Problema, então o Enunciado já
  # nasce com a seção.
  test "new opens the statement on the template that ends with how to read the input" do
    get new_staff_problem_path

    assert_select "textarea[name=?]", "problem[statement]", text: /## Como ler a entrada.*input\(\)/m
  end

  test "staff registers a problem and its position comes for free" do
    assert_difference -> { contests(:maratona).problems.count }, +1 do
      post staff_problems_path, params: { problem: {
        title: "Soma de vetor", difficulty: "medium",
        statement: "## Entrada\n\nUma linha.\n", reference_solution: "print(1)\n" } }
    end

    problem = contests(:maratona).problems.ordered.last
    assert_equal 4, problem.position
    assert_redirected_to staff_problem_path(problem)
  end

  test "show renders the statement, the reference solution and the testcases" do
    get staff_problem_path(problems(:easy_sum))

    assert_response :success
    assert_select "h1", "Soma de dois números"
    assert_select "pre", text: /7/
  end

  test "edit renders the form" do
    get edit_staff_problem_path(problems(:easy_sum))

    assert_response :success
    assert_select "input[name=?][value=?]", "problem[title]", "Soma de dois números"
  end

  # A saída esperada foi gerada pela referência antiga: trocá-la por uma que falha mudaria
  # as respostas em silêncio (ADR-0003).
  test "a reference solution that fails the existing testcases is refused" do
    patch staff_problem_path(problems(:easy_sum)),
      params: { problem: { reference_solution: "a, b = map(int, input().split())\nprint(a - b)\n" } }

    assert_response :unprocessable_entity
    assert_no_changes -> { problems(:easy_sum).reload.reference_solution } do
      problems(:easy_sum).reload
    end
  end

  test "staff edits the title without starting a container" do
    patch staff_problem_path(problems(:easy_sum)), params: { problem: { title: "Soma simples" } }

    assert_redirected_to staff_problem_path(problems(:easy_sum))
    assert_equal "Soma simples", problems(:easy_sum).reload.title
  end

  test "staff deletes a problem" do
    assert_difference -> { Problem.count }, -1 do
      delete staff_problem_path(problems(:hard_fibonacci))
    end

    assert_redirected_to staff_problems_path
  end
end
