module ProblemScoped
  extend ActiveSupport::Concern

  private
    # O Problema é identificado pela posição na Competição, nunca pelo id.
    def set_problem
      @problem = contest.problems.find_by! position: params[:problem_id] || params[:id]
    end
end
