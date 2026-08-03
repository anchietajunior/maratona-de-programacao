# rbs_inline: enabled

# Liga a Submissão ao Juiz: toda Submissão nasce pendente e é julgada em segundo plano.
module Submission::Judgeable
  extend ActiveSupport::Concern

  included do
    after_create_commit :judge_later
  end

  #: () -> void
  def judge_later
    Submission::JudgeJob.perform_later(self)
  end

  #: () -> void
  def judge_now
    update! verdict: Judge.new.judge(code, problem.judging_cases).verdict
  end
end
