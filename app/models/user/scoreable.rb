# rbs_inline: enabled

# Pontuação e Tempo Acumulado da Equipe. Tudo aqui é derivado do conjunto de Submissões a
# cada chamada — nada é acumulado em coluna (ADR-0010).
module User::Scoreable
  extend ActiveSupport::Concern

  # Minutos somados ao Tempo Acumulado por tentativa errada (Art. 31-III).
  PENALTY = 10

  class_methods do
    # A Classificação, do primeiro ao último (Art. 28-33).
    #: () -> Array[User]
    def standings
      competing.includes(submissions: { problem: :contest }).sort_by(&:standing_key)
    end
  end

  # A primeira Submissão aceita de cada Problema. O Art. 27 permite submeter depois do AC,
  # e essas Submissões seguintes não pontuam nem penalizam de novo.
  #: () -> Array[Submission]
  def solutions
    submissions.select(&:accepted?).sort_by(&:created_at).uniq(&:problem_id)
  end

  # Os Problemas resolvidos, na ordem em que aparecem na Competição.
  #: () -> Array[Problem]
  def solved_problems
    solutions.map(&:problem).sort_by(&:position)
  end

  # Só AC pontua, e vale o Nível de Dificuldade cheio (Art. 29, 30).
  #: () -> Integer
  def score
    solved_problems.sum(&:points)
  end

  # Para cada Problema resolvido, o tempo até o AC mais a Penalidade das tentativas que o
  # precederam (Art. 31).
  #: () -> Integer
  def total_time
    solutions.sum { |solution| solution.elapsed_minutes + penalty_for(solution) }
  end

  #: (Problem) -> bool
  def solved?(problem)
    solutions.any? { |solution| solution.problem_id == problem.id }
  end

  #: (Problem) -> Array[Submission]
  def submissions_on(problem)
    submissions.select { |submission| submission.problem_id == problem.id }
               .sort_by(&:created_at)
  end

  #: (Problem) -> Integer
  def attempts_on(problem)
    submissions_on(problem).size
  end

  # A ordem da Classificação: maior Pontuação, menor Tempo Acumulado e, persistindo o
  # empate, o Problema mais difícil resolvido — o mais cedo entre eles (Art. 33). A
  # identificação fecha a chave para que empate absoluto não saia em ordem sorteada.
  #: () -> Array[untyped]
  def standing_key
    [ -score, total_time, -hardest_points, hardest_time, nickname ]
  end

  private
    # Dez minutos por tentativa errada **anterior** ao AC. As posteriores não contam: a
    # Penalidade paga o caminho até a solução, e esse caminho terminou.
    #: (Submission) -> Integer
    def penalty_for(solution)
      PENALTY * submissions.count do |submission|
        submission.problem_id == solution.problem_id &&
          submission.incorrect? &&
          submission.created_at < solution.created_at
      end
    end

    # A Submissão que resolveu o Problema mais difícil; entre iguais, a mais antiga.
    #: () -> Submission?
    def hardest_solution
      solutions.max_by { |solution| [ solution.problem.points, -solution.created_at.to_f ] }
    end

    #: () -> Integer
    def hardest_points
      hardest_solution&.problem&.points || 0
    end

    #: () -> Float
    def hardest_time
      hardest_solution&.created_at&.to_f || Float::INFINITY
    end
end
