class Staff::StandingsController < Staff::BaseController
  def show
    @teams = User.standings
    @problems = contest.problems.ordered
  end
end
