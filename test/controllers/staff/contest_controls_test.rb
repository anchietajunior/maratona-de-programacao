require "test_helper"

# Iniciar, encerrar e divulgar são três mudanças de estado da Competição, cada uma com o
# seu recurso.
class Staff::ContestControlsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup { sign_in_as users(:technical_committee) }

  test "starting the contest sets the zero mark" do
    contests(:maratona).update! started_at: nil

    post staff_start_path

    assert contests(:maratona).reload.open?
    assert_redirected_to staff_root_path
  end

  test "closing the contest shuts the window" do
    post staff_closure_path

    assert contests(:maratona).reload.ended?
    assert_redirected_to staff_root_path
  end

  # Reiniciar é ferramenta de ensaio: sem apagar a rodada, as Submissões antigas ficariam
  # com instante anterior ao novo marco zero e o Tempo Acumulado sairia negativo.
  # Apagar a rodada inteira mexe em três tabelas e dispara broadcast por registro: o
  # pedido devolve a tela na hora e o trabalho fica com o worker.
  test "restarting hands the work to a background job" do
    assert_enqueued_with job: Contest::RestartJob do
      delete staff_start_path
    end

    assert contests(:maratona).reload.started?
  end

  test "restarting clears the clock and the round it produced" do
    Delivery.create! user: users(:turing), problem: problems(:easy_sum), staff: users(:technical_committee)

    perform_enqueued_jobs { delete staff_start_path }

    assert_not contests(:maratona).reload.started?
    assert_empty Submission.all
    assert_empty Clarification.all
    assert_empty Delivery.all
    assert_redirected_to staff_root_path
  end

  test "restarting keeps the problems and their testcases" do
    perform_enqueued_jobs { delete staff_start_path }

    assert_equal 3, contests(:maratona).reload.problems.count
    assert_equal 2, problems(:easy_sum).testcases.count
  end

  test "a restarted contest can be started again from zero" do
    perform_enqueued_jobs { delete staff_start_path }
    post staff_start_path

    assert contests(:maratona).reload.open?
    assert_equal 0, contests(:maratona).minutes_until(Time.current)
  end

  test "publishing opens the standings to the teams" do
    post staff_publication_path

    assert contests(:maratona).reload.published?
    assert_redirected_to staff_standings_path
  end

  test "the publication can be withdrawn" do
    contests(:maratona).publish

    delete staff_publication_path

    assert_not contests(:maratona).reload.published?
  end

  test "a team controls nothing" do
    sign_out
    sign_in_as users(:turing)

    post staff_start_path

    assert_response :forbidden
  end
end
