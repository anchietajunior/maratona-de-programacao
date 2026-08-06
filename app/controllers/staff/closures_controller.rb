class Staff::ClosuresController < Staff::BaseController
  def create
    contest.finish
    redirect_to staff_root_url, notice: t(".closed")
  end
end
