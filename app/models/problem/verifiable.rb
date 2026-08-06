# rbs_inline: enabled

# A Solução de Referência é a autoridade sobre o Problema: é ela que gera a saída esperada
# de cada Caso de Teste (ADR-0003). Trocá-la sem que ela passe nos Casos de Teste que já
# existem mudaria as respostas em silêncio, então o Problema recusa a troca.
module Problem::Verifiable
  extend ActiveSupport::Concern

  included do
    validate :reference_solution_must_pass, if: :reference_solution_changed?, on: :update
  end

  # O Veredicto da Solução de Referência contra os Casos de Teste do próprio Problema.
  #: () -> String
  def reference_verdict
    Judge.new.judge(reference_solution, judging_cases).verdict
  end

  private
    #: () -> void
    def reference_solution_must_pass
      if testcases.any? && reference_verdict != "AC"
        errors.add :reference_solution, :rejected
      end
    end
end
