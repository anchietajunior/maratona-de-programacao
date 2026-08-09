class Staff::StartsController < Staff::BaseController
  # Iniciar é o marco zero de todo cálculo de tempo (ADR-0008).
  def create
    contest.start
    redirect_to staff_root_url, notice: t(".started")
  end

  # Reiniciar é desfazer o início: o marco zero deixa de existir e a rodada vai junto.
  def destroy
    contest.restart_later
    redirect_to staff_root_url, notice: t(".restarted"), status: :see_other
  end
end
