# rbs_inline: enabled

class Problem < ApplicationRecord
  # Nível de Dificuldade e o que cada um vale (Art. 19).
  POINTS = { easy: 10, medium: 20, hard: 30 }.freeze

  belongs_to :contest
  has_many :testcases, dependent: :destroy
  has_many :submissions, dependent: :destroy

  enum :difficulty, POINTS.keys.index_with(&:to_s), validate: true

  scope :ordered, -> { order(:position) }

  validates :title, :statement, :reference_solution, presence: true
  validates :position, presence: true, uniqueness: { scope: :contest_id }

  # A posição é a identidade do Problema na Competição, não o id.
  #: () -> String?
  def to_param = position&.to_s

  #: () -> Integer
  def points = POINTS.fetch(difficulty.to_sym)

  # Os Casos de Teste no formato que o Juiz consome.
  #: () -> Array[Hash[Symbol, String]]
  def judging_cases
    testcases.map { |testcase| { input: testcase.input, expected: testcase.expected_output } }
  end
end
