# rbs_inline: enabled

class Submission < ApplicationRecord
  include Broadcastable, Judgeable

  VERDICTS = %w[ AC WA PE TLE MLE RE CE ].freeze

  belongs_to :user, default: -> { Current.user }
  belongs_to :problem

  scope :chronologically, -> { order(:created_at) }
  scope :reverse_chronologically, -> { order(created_at: :desc) }
  scope :accepted, -> { where(verdict: "AC") }
  scope :pending, -> { where(verdict: nil) }
  scope :incorrect, -> { where.not(verdict: [ nil, "AC" ]) }

  validates :code, presence: true
  validates :verdict, inclusion: { in: VERDICTS }, allow_nil: true
  validate :contest_must_be_open, on: :create

  # Veredicto nulo é Submissão ainda não julgada.
  #: () -> bool
  def judged? = verdict.present?

  # Único Veredicto que pontua (Art. 30).
  #: () -> bool
  def accepted? = verdict == "AC"

  # Submissão julgada que não foi aceita — é o que gera Penalidade (Art. 31).
  #: () -> bool
  def incorrect? = judged? && !accepted?

  # Minutos desde o início real da Competição até esta Submissão (Art. 31, ADR-0008).
  #: () -> Integer
  def elapsed_minutes
    problem.contest.minutes_until(created_at)
  end

  private
    # Fora da janela não se submete: nem antes do início, nem depois do encerramento
    # (Art. 20). Dentro dela não há limite nenhum, nem depois do AC (Art. 27).
    #: () -> void
    def contest_must_be_open
      errors.add :base, :contest_closed unless problem&.contest&.open?
    end
end
