# rbs_inline: enabled

class Contest::RestartJob < ApplicationJob
  #: (Contest) -> void
  def perform(contest)
    contest.restart_now
  end
end
