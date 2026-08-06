# rbs_inline: enabled

class Testcase < ApplicationRecord
  include Generated

  belongs_to :problem

  # O <textarea> devolve quebras de linha como CRLF. Guardar o \r faria duas soluções
  # corretas imprimirem saídas diferentes — quem lê com input() carrega o \r, quem usa
  # strip() não — e a que a Comissão escreveu viraria a única "certa" (Art. 24).
  # A saída esperada não passa por aqui: ela é o que o programa imprimiu, byte a byte.
  normalizes :input, with: ->(input) { input.gsub("\r\n", "\n") }

  scope :chronologically, -> { order(:created_at) }

  # Sem validação de presença: há Problema que não lê entrada e Problema que não imprime
  # saída. Vazio é legítimo, nulo o banco já recusa.
end
