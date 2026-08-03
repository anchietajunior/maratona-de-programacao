class Testcase < ApplicationRecord
  belongs_to :problem

  # Sem validação de presença: há Problema que não lê entrada e Problema que não imprime
  # saída. Vazio é legítimo, nulo o banco já recusa.
end
