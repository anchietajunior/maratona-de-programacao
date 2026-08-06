class ProblemsController < ApplicationController
  include ProblemScoped

  before_action :ensure_contest_started
  before_action :set_problem, only: :show

  def index
    @problems = contest.problems.ordered
  end

  def show
    @submissions = Current.user.submissions_on(@problem).reverse
  end

  private
    def ensure_contest_started
      redirect_to scoreboard_url unless contest.started?
    end
end
