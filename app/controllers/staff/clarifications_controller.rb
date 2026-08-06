class Staff::ClarificationsController < Staff::BaseController
  def index
    @clarifications = Clarification.includes(:user, :problem, :answer).reverse_chronologically
  end
end
