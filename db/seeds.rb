# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

password = ENV.fetch("SEED_PASSWORD", "12345")

{ "staff01" => "Comissão Organizadora", "staff02" => "Comissão Técnica" }.each do |nickname, name|
  User.find_or_create_by!(nickname: nickname) do |user|
    user.name = name
    user.password = password
    user.staff = true
  end
end

15.times do |index|
  number = format("%02d", index + 1)

  User.find_or_create_by!(nickname: "equipe#{number}") do |user|
    user.name = "Equipe #{number}"
    user.password = password
  end
end

contest = Contest.first_or_create!

# Os Problemas moram aqui. A posição é explícita porque ela é a identidade do Problema na
# Competição, e a ordem não pode depender de quem foi inserido primeiro.
#
# A saída esperada dos Casos de Teste **não** aparece neste arquivo: só a entrada. Ela nasce
# de rodar a Solução de Referência em contêiner (ADR-0003), o que faz este seed exigir
# Docker — inclusive no db:seed:replant do bin/ci.
palindrome = contest.problems.find_or_create_by!(title: "Palíndromo") do |problem|
  problem.position = 1
  problem.difficulty = "easy"
  problem.statement = <<~MD
    Uma palavra é palíndroma quando se lê igual de trás para frente. Dada uma palavra, diga
    se ela é palíndroma.

    ## Entrada

    Uma única linha com uma palavra, formada apenas por letras minúsculas sem acento.

    ## Saída

    Uma única linha com `SIM`, se a palavra for palíndroma, ou `NAO`, caso contrário.

    ## Exemplo

    Para a entrada

    ```
    arara
    ```

    a saída é

    ```
    SIM
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão: `input()` devolve a linha inteira, já sem a
    quebra de linha. Não peça nada ao usuário.

    ```
    palavra = input()
    ```
  MD
  problem.reference_solution = <<~PY
    palavra = input()
    print("SIM" if palavra == palavra[::-1] else "NAO")
  PY
end

# Cada caso derruba um erro diferente: "osso" pega quem só trata tamanho ímpar, e "abca"
# pega quem compara apenas a primeira letra com a última.
[ "arara\n", "osso\n", "abca\n" ].each do |input|
  palindrome.testcases.find_or_create_by! input: input
end
