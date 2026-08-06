class Staff::SessionsController < Staff::BaseController
  # Encerrar a Sessão de uma Equipe é o que libera o login quando a máquina dela trava
  # (ADR-0009).
  def destroy
    Session.find(params[:id]).destroy
    redirect_to staff_root_url, notice: t(".destroyed"), status: :see_other
  end
end
