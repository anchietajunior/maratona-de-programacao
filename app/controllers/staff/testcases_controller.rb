class Staff::TestcasesController < Staff::BaseController
  include ProblemScoped

  before_action :set_problem

  # Só a entrada vem do formulário: a saída esperada é gerada pela Solução de Referência,
  # nunca digitada (ADR-0003).
  def create
    @testcase = @problem.testcases.new testcase_params

    if @testcase.save
      redirect_to staff_problem_url(@problem), notice: t(".created")
    else
      redirect_to staff_problem_url(@problem), alert: @testcase.errors.full_messages.to_sentence
    end
  end

  def destroy
    @problem.testcases.find(params[:id]).destroy
    redirect_to staff_problem_url(@problem), notice: t(".destroyed"), status: :see_other
  end

  private
    def testcase_params
      params.expect(testcase: [ :input ])
    end
end
