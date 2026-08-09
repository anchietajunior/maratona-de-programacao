module ApplicationHelper
  # O que o Enunciado pode conter. Formato de entrada e saída pede tabela e bloco de
  # código, e nada além disso precisa passar.
  STATEMENT_TAGS = %w[
    h1 h2 h3 h4 h5 h6 p br hr ul ol li strong em code pre blockquote
    table thead tbody tr th td
  ].freeze

  # O Enunciado é Markdown escrito pela Comissão Técnica, renderizado por kramdown — Ruby
  # puro, sem extensão nativa para compilar na máquina do laboratório (ADR-0005).
  def markdown(text)
    fenced = text.to_s.gsub(/^ {0,3}```/, "~~~")

    sanitize Kramdown::Document.new(fenced).to_html, tags: STATEMENT_TAGS
  end

  # Minutos são a unidade do Tempo Acumulado (Art. 31).
  def in_minutes(count)
    t("shared.minutes", count: count)
  end
end
