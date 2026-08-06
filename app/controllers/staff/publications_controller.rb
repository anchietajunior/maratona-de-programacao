class Staff::PublicationsController < Staff::BaseController
  # Publicar é o que torna a Classificação visível às Equipes, na premiação (Art. 28).
  def create
    contest.publish
    redirect_to staff_standings_url, notice: t(".published")
  end

  def destroy
    contest.unpublish
    redirect_to staff_standings_url, notice: t(".withdrawn"), status: :see_other
  end
end
