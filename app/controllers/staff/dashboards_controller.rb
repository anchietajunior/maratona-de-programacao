class Staff::DashboardsController < Staff::BaseController
  def show
    @teams = User.competing
  end
end
