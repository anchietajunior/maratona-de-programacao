class SubmissionsController < ApplicationController
  include ProblemScoped

  before_action :set_problem

  def create
    @submission = @problem.submissions.new submission_params

    if @submission.save
      redirect_to problem_url(@problem), notice: t(".created")
    else
      redirect_to problem_url(@problem), alert: @submission.errors.full_messages.to_sentence
    end
  end

  private
    def submission_params
      params.expect(submission: [ :code ])
    end
end
