# rbs_inline: enabled

class User < ApplicationRecord
  include Scoreable

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :clarifications, dependent: :destroy
  has_many :deliveries, dependent: :destroy

  normalizes :nickname, with: ->(nickname) { nickname.strip.downcase }

  validates :name, presence: true

  scope :competing, -> { where(staff: false) }

  # Uma Equipe usa um computador só, então já tem Sessão ativa em outra máquina.
  # Staff não tem essa restrição (ADR-0009, Art. 21).
  #: () -> bool
  def signed_in_elsewhere?
    !staff? && sessions.active.any?
  end
end
