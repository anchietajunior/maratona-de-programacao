class ScoreboardsController < ApplicationController
  def show
    @problems = contest.problems.ordered
  end
end
