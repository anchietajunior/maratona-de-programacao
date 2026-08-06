class Staff::BalloonsController < Staff::BaseController
  # Um Balão é devido a cada Problema resolvido, e todos são da mesma cor justamente para
  # que ninguém deduza desempenho alheio olhando a sala (Art. 25).
  def index
    @teams = User.competing.includes(:deliveries, submissions: { problem: :contest })
                 .order(:nickname).select { |team| team.solved_problems.any? }
  end
end
