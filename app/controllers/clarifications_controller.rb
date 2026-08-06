class ClarificationsController < ApplicationController
  include ProblemScoped

  before_action :set_problem, only: :create

  def index
    @clarifications = Current.user.clarifications.includes(:problem, :answer).reverse_chronologically
    @announcements = Clarification.collective.includes(:problem, :answer).reverse_chronologically
  end

  def create
    @clarification = @problem.clarifications.new clarification_params

    if @clarification.save
      redirect_to clarifications_url, notice: t(".created")
    else
      redirect_to problem_url(@problem), alert: @clarification.errors.full_messages.to_sentence
    end
  end

  private
    def clarification_params
      params.expect(clarification: [ :question ])
    end
end
