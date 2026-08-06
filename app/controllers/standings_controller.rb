class StandingsController < ApplicationController
  before_action :ensure_published

  def show
    @teams = User.standings
    @problems = contest.problems.ordered
  end

  private
    # Para a Equipe, a Classificação só existe depois da premiação (Art. 28).
    def ensure_published
      redirect_to scoreboard_url, alert: t(".unpublished") unless contest.published?
    end
end
