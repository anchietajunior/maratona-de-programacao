# rbs_inline: enabled

# A saída esperada nunca é digitada: ela é exatamente o que a Solução de Referência imprime
# para a entrada informada (ADR-0003). Se a referência não roda naquela entrada, o Caso de
# Teste não existe.
module Testcase::Generated
  extend ActiveSupport::Concern

  included do
    validate :generate_expected_output, on: :create
  end

  private
    #: () -> void
    def generate_expected_output
      if problem && input
        self.expected_output = Judge.new.run(problem.reference_solution, input)
      end
    rescue Judge::Failed => error
      errors.add :input, :reference_failed, verdict: error.verdict
    end
end
