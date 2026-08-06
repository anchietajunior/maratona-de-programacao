module SubmissionsHelper
  # O Veredicto em pílula. A cor separa três estados que a Equipe precisa distinguir de
  # relance: aceito, recusado, ainda julgando.
  def verdict_badge(submission)
    tag.span verdict_sigla(submission),
      class: [ "inline-block rounded-md bg-surface-strong px-xs py-xxs text-caption-uppercase uppercase",
               verdict_color(submission) ],
      title: verdict_meaning(submission)
  end

  # O que a sigla quer dizer, em português — a Equipe não é obrigada a saber o jargão.
  def verdict_meaning(submission)
    if submission.judged?
      t "submissions.verdicts.#{submission.verdict}"
    else
      t "submissions.verdicts.pending"
    end
  end

  private
    def verdict_sigla(submission)
      if submission.judged?
        submission.verdict
      else
        t "submissions.verdicts.pending_sigla"
      end
    end

    def verdict_color(submission)
      if submission.accepted?
        "text-success"
      elsif submission.judged?
        "text-error"
      else
        "text-muted"
      end
    end
end
