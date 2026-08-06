# rbs_inline: enabled

class Contest < ApplicationRecord
  # Três horas contadas do início real, nunca de um horário de parede (ADR-0008).
  DURATION = 3.hours

  has_many :problems, dependent: :destroy

  # Há uma única Competição no sistema (Art. 20).
  #: () -> Contest?
  def self.current = first

  #: () -> void
  def start
    update! started_at: Time.current unless started?
  end

  #: () -> void
  def finish
    update! ended_at: Time.current if open?
  end

  # Devolve a Competição ao estado anterior ao início e apaga o que a rodada produziu.
  # Apagar não é opcional: o Tempo Acumulado é contado do marco zero, e Submissão anterior
  # a um marco zero novo sairia com tempo negativo. Problemas e Casos de Teste ficam.
  #: () -> void
  def restart
    transaction do
      Submission.where(problem: problems).destroy_all
      Clarification.where(problem: problems).destroy_all
      Delivery.where(problem: problems).destroy_all

      update! started_at: nil, ended_at: nil, published_at: nil
    end
  end

  # A Classificação só fica visível às Equipes depois da premiação (Art. 28).
  #: () -> void
  def publish
    update! published_at: Time.current unless published?
  end

  #: () -> void
  def unpublish
    update! published_at: nil
  end

  #: () -> bool
  def started? = started_at.present?

  #: () -> bool
  def published? = published_at.present?

  # O instante do encerramento: três horas depois do início, ou antes, se a Comissão
  # encerrar na mão.
  #: () -> Time?
  def deadline
    [ started_at + DURATION, ended_at ].compact.min if started?
  end

  #: () -> bool
  def open? = started? && Time.current < deadline

  #: () -> bool
  def ended? = started? && Time.current >= deadline

  # Segundos que faltam para o encerramento, nunca negativo.
  #: () -> Integer
  def remaining
    if started?
      [ deadline - Time.current, 0 ].max.to_i
    else
      DURATION.to_i
    end
  end

  # Minutos inteiros entre o início real e o instante, que é como o Tempo Acumulado é
  # contado (Art. 31).
  #: (Time) -> Integer
  def minutes_until(instant)
    ((instant - started_at) / 60).floor
  end
end
