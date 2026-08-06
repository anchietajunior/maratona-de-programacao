# rbs_inline: enabled

# O Veredicto chega sozinho à tela da própria Equipe e ao monitor da Comissão. Nenhum
# fluxo aqui alcança outra Equipe: o que é secreto é a posição, não o Veredicto (Art. 34).
module Submission::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes_to ->(submission) { submission.user }
    broadcasts_refreshes_to ->(submission) { :staff_submissions }
  end
end
