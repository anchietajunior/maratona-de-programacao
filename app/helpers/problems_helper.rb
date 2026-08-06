module ProblemsHelper
  # O Nível de Dificuldade é público desde o início (Art. 19).
  def difficulty_badge(problem)
    tag.span t("problems.difficulties.#{problem.difficulty}"),
      class: "inline-block rounded-md bg-surface-strong px-xs py-xxs text-caption-uppercase uppercase text-ink"
  end
end
