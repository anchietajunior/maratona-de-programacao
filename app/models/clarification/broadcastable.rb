# rbs_inline: enabled

# O Pedido aparece na fila da Comissão e na tela de quem perguntou, sem que ninguém
# recarregue nada.
module Clarification::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes_to ->(clarification) { :staff_clarifications }
    broadcasts_refreshes_to ->(clarification) { clarification.user }
  end
end
