module TestcasesHelper
  # Entrada e saída esperada vivem em coluna binária para que o banco não opine sobre
  # igualdade de texto (ADR-0003). Na tela, elas voltam a ser texto.
  def as_text(bytes)
    bytes.to_s.dup.force_encoding(Encoding::UTF_8)
  end
end
