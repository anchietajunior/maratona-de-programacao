# rbs_inline: enabled

# Pedido de Esclarecimento: dúvida da Equipe sobre o Enunciado de um Problema (Art. 35).
class Clarification < ApplicationRecord
  include Broadcastable

  belongs_to :user, default: -> { Current.user }
  belongs_to :problem
  has_one :answer, dependent: :destroy

  scope :chronologically, -> { order(:created_at) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
  scope :answered, -> { joins(:answer) }
  scope :unanswered, -> { where.missing(:answer) }
  scope :collective, -> { joins(:answer).where(answers: { collective: true }) }

  validates :question, presence: true
  validate :contest_must_be_open, on: :create

  #: () -> bool
  def answered? = answer.present?

  private
    # Dúvida se pergunta durante a Competição (Art. 35).
    #: () -> void
    def contest_must_be_open
      errors.add :base, :contest_closed unless problem&.contest&.open?
    end
end
