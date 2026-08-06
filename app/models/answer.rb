# rbs_inline: enabled

# A Resposta da Comissão Técnica a um Pedido de Esclarecimento (Art. 36). Quando o assunto
# é de interesse coletivo, ela vai para todas as Equipes.
class Answer < ApplicationRecord
  include Broadcastable

  belongs_to :clarification
  belongs_to :user, default: -> { Current.user }

  validates :body, presence: true
end
