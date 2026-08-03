# rbs_inline: enabled

class Submission < ApplicationRecord
  include Judgeable

  VERDICTS = %w[ AC WA PE TLE MLE RE CE ].freeze

  belongs_to :user, default: -> { Current.user }
  belongs_to :problem

  scope :chronologically, -> { order(:created_at) }
  scope :accepted, -> { where(verdict: "AC") }
  scope :pending, -> { where(verdict: nil) }

  validates :code, presence: true
  validates :verdict, inclusion: { in: VERDICTS }, allow_nil: true

  # Veredicto nulo é Submissão ainda não julgada.
  #: () -> bool
  def judged? = verdict.present?

  # Único Veredicto que pontua (Art. 30).
  #: () -> bool
  def accepted? = verdict == "AC"
end
