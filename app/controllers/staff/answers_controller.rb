class Staff::AnswersController < Staff::BaseController
  before_action :set_clarification

  def create
    if @clarification.answered?
      redirect_to staff_clarifications_url, alert: t(".already_answered")
    else
      @clarification.create_answer! answer_params
      redirect_to staff_clarifications_url, notice: t(".created")
    end
  end

  private
    def set_clarification
      @clarification = Clarification.find params[:clarification_id]
    end

    def answer_params
      params.expect(answer: [ :body, :collective ])
    end
end
