# rbs_inline: enabled

# A Resposta chega a quem perguntou e à fila da Comissão. Sendo de interesse coletivo, vai
# também ao mural que todas as Equipes acompanham — e só ele é compartilhado, porque nada
# do que trafega nele é de uma Equipe (Art. 34, 36).
module Answer::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes_to ->(answer) { answer.clarification.user }
    broadcasts_refreshes_to ->(answer) { :staff_clarifications }
    after_create_commit -> { broadcast_refresh_later_to :announcements }, if: :collective?
  end
end
