class Staff::ProblemsController < Staff::BaseController
  include ProblemScoped

  before_action :set_problem, only: %i[ show edit update destroy ]

  def index
    @problems = contest.problems.ordered
  end

  def show
    @testcase = @problem.testcases.new
  end

  def new
    @problem = contest.problems.new statement: t("staff.problems.form.statement_template")
  end

  def create
    @problem = contest.problems.new problem_params

    if @problem.save
      redirect_to staff_problem_url(@problem), notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @problem.update problem_params
      redirect_to staff_problem_url(@problem), notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @problem.destroy
    redirect_to staff_problems_url, notice: t(".destroyed"), status: :see_other
  end

  private
    def problem_params
      params.expect(problem: [ :title, :difficulty, :statement, :reference_solution ])
    end
end
