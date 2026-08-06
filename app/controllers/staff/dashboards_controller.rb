class Staff::DashboardsController < Staff::BaseController
  def show
    @teams = User.competing.includes(:sessions).order(:nickname)
    @problems = contest.problems.ordered
  end
end
