# rbs_inline: enabled

class Submission::JudgeJob < ApplicationJob
  #: (Submission) -> void
  def perform(submission)
    submission.judge_now
  end
end
