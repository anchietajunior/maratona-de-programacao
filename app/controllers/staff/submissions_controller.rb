class Staff::SubmissionsController < Staff::BaseController
  def index
    @submissions = Submission.includes(:user, :problem).reverse_chronologically
  end
end
