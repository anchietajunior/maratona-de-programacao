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

odd_or_even = contest.problems.find_or_create_by!(title: "Par ou Ímpar") do |problem|
  problem.position = 2
  problem.difficulty = "easy"
  problem.statement = <<~MD
    Dado um número inteiro, diga se ele é par ou ímpar.

    ## Entrada

    Uma única linha com um número inteiro entre 0 e 1.000.000.

    ## Saída

    Uma única linha com `PAR`, se o número for par, ou `IMPAR`, caso contrário.

    ## Exemplo

    Para a entrada

    ```
    7
    ```

    a saída é

    ```
    IMPAR
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão. `input()` devolve texto: converta para
    número com `int()`. Não peça nada ao usuário.

    ```
    numero = int(input())
    ```
  MD
  problem.reference_solution = <<~PY
    numero = int(input())
    print("PAR" if numero % 2 == 0 else "IMPAR")
  PY
end

# O zero é par — pega quem trata "menor que um" como caso especial.
[ "4\n", "7\n", "0\n" ].each do |input|
  odd_or_even.testcases.find_or_create_by! input: input
end

vowel_count = contest.problems.find_or_create_by!(title: "Contagem de Vogais") do |problem|
  problem.position = 3
  problem.difficulty = "easy"
  problem.statement = <<~MD
    Dada uma palavra, conte quantas de suas letras são vogais (`a`, `e`, `i`, `o`, `u`).

    ## Entrada

    Uma única linha com uma palavra, formada apenas por letras minúsculas sem acento.

    ## Saída

    Uma única linha com a quantidade de vogais da palavra.

    ## Exemplo

    Para a entrada

    ```
    programa
    ```

    a saída é

    ```
    3
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
    total = 0
    for letra in palavra:
        if letra in "aeiou":
            total += 1
    print(total)
  PY
end

# "fgh" pega quem assume que sempre existe vogal, e "aeiou" pega quem esqueceu uma vogal
# na lista.
[ "programa\n", "fgh\n", "aeiou\n" ].each do |input|
  vowel_count.testcases.find_or_create_by! input: input
end

grade_average = contest.problems.find_or_create_by!(title: "Média das Notas") do |problem|
  problem.position = 4
  problem.difficulty = "easy"
  problem.statement = <<~MD
    Um estudante fez três provas. Calcule a média das três notas.

    ## Entrada

    Três linhas, cada uma com uma nota entre 0 e 10, escrita com uma casa decimal.

    ## Saída

    Uma única linha com a média das três notas, arredondada para **exatamente uma casa
    decimal** — `8.0`, e não `8`.

    ## Exemplo

    Para a entrada

    ```
    7.0
    8.0
    9.0
    ```

    a saída é

    ```
    8.0
    ```

    ## Como ler a entrada e imprimir a saída

    A entrada chega pronta pela entrada padrão. `input()` devolve texto: converta para
    número com `float()`. Não peça nada ao usuário.

    ```
    nota1 = float(input())
    nota2 = float(input())
    nota3 = float(input())
    ```

    Para imprimir com uma casa decimal, use uma f-string:

    ```
    print(f"{media:.1f}")
    ```
  MD
  problem.reference_solution = <<~PY
    nota1 = float(input())
    nota2 = float(input())
    nota3 = float(input())
    media = (nota1 + nota2 + nota3) / 3
    print(f"{media:.1f}")
  PY
end

# A dízima 17/3 = 5.666... pega quem imprime a divisão crua ou trunca em vez de arredondar.
[ "7.0\n8.0\n9.0\n", "5.0\n6.0\n6.0\n", "10.0\n10.0\n10.0\n" ].each do |input|
  grade_average.testcases.find_or_create_by! input: input
end

fibonacci = contest.problems.find_or_create_by!(title: "Fibonacci") do |problem|
  problem.position = 5
  problem.difficulty = "medium"
  problem.statement = <<~MD
    Na sequência de Fibonacci, os dois primeiros termos valem 1 e cada termo seguinte é a
    soma dos dois anteriores: 1, 1, 2, 3, 5, 8, 13, ...

    Dado N, imprima o N-ésimo termo da sequência.

    ## Entrada

    Uma única linha com um número inteiro N, com 1 ≤ N ≤ 60.

    ## Saída

    Uma única linha com o N-ésimo termo da sequência de Fibonacci.

    ## Exemplo

    Para a entrada

    ```
    10
    ```

    a saída é

    ```
    55
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão. `input()` devolve texto: converta para
    número com `int()`. Não peça nada ao usuário.

    ```
    n = int(input())
    ```
  MD
  problem.reference_solution = <<~PY
    n = int(input())
    a, b = 1, 1
    for _ in range(n - 1):
        a, b = b, a + b
    print(a)
  PY
end

# "1" pega o erro de um a menos no laço, e "60" derruba a recursão ingênua por tempo.
[ "1\n", "10\n", "60\n" ].each do |input|
  fibonacci.testcases.find_or_create_by! input: input
end

prime = contest.problems.find_or_create_by!(title: "Número Primo") do |problem|
  problem.position = 6
  problem.difficulty = "medium"
  problem.statement = <<~MD
    Um número é primo quando é maior que 1 e é divisível apenas por 1 e por ele mesmo.
    Dado um número, diga se ele é primo.

    ## Entrada

    Uma única linha com um número inteiro N, com 1 ≤ N ≤ 1.000.000.000.000.

    ## Saída

    Uma única linha com `SIM`, se o número for primo, ou `NAO`, caso contrário.

    ## Exemplo

    Para a entrada

    ```
    13
    ```

    a saída é

    ```
    SIM
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão. `input()` devolve texto: converta para
    número com `int()`. Não peça nada ao usuário.

    ```
    numero = int(input())
    ```
  MD
  problem.reference_solution = <<~PY
    numero = int(input())
    if numero < 2:
        primo = False
    else:
        primo = True
        divisor = 2
        while divisor * divisor <= numero:
            if numero % divisor == 0:
                primo = False
                break
            divisor += 1
    print("SIM" if primo else "NAO")
  PY
end

# "2" pega quem descarta todos os pares, "1" pega quem acha que 1 é primo, "25" pega o
# laço que para antes da raiz quadrada, e o primo gigante derruba o laço que vai até N.
[ "2\n", "1\n", "25\n", "999999999989\n" ].each do |input|
  prime.testcases.find_or_create_by! input: input
end

anagram = contest.problems.find_or_create_by!(title: "Anagramas") do |problem|
  problem.position = 7
  problem.difficulty = "medium"
  problem.statement = <<~MD
    Duas palavras são anagramas quando uma pode ser formada reorganizando as letras da
    outra, usando cada letra exatamente o mesmo número de vezes. Dadas duas palavras, diga
    se elas são anagramas.

    ## Entrada

    Duas linhas, cada uma com uma palavra formada apenas por letras minúsculas sem acento.

    ## Saída

    Uma única linha com `SIM`, se as palavras forem anagramas, ou `NAO`, caso contrário.

    ## Exemplo

    Para a entrada

    ```
    amor
    roma
    ```

    a saída é

    ```
    SIM
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão: cada chamada de `input()` devolve uma
    linha, já sem a quebra de linha. Não peça nada ao usuário.

    ```
    primeira = input()
    segunda = input()
    ```
  MD
  problem.reference_solution = <<~PY
    primeira = input()
    segunda = input()
    print("SIM" if sorted(primeira) == sorted(segunda) else "NAO")
  PY
end

# "amora"/"roma" têm as mesmas letras em quantidades diferentes — pega quem compara
# conjuntos de letras. "aabb"/"abab" pega quem exige as repetições na mesma ordem.
[ "amor\nroma\n", "amora\nroma\n", "aabb\nabab\n" ].each do |input|
  anagram.testcases.find_or_create_by! input: input
end

gcd = contest.problems.find_or_create_by!(title: "Máximo Divisor Comum") do |problem|
  problem.position = 8
  problem.difficulty = "medium"
  problem.statement = <<~MD
    O máximo divisor comum de dois números é o maior número que divide os dois sem deixar
    resto. Dados dois números, calcule o máximo divisor comum entre eles.

    ## Entrada

    Uma única linha com dois números inteiros A e B separados por um espaço, com
    1 ≤ A, B ≤ 1.000.000.000.000.

    ## Saída

    Uma única linha com o máximo divisor comum de A e B.

    ## Exemplo

    Para a entrada

    ```
    12 18
    ```

    a saída é

    ```
    6
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão. `split()` separa a linha pelos espaços;
    converta cada parte com `int()`. Não peça nada ao usuário.

    ```
    a, b = input().split()
    a = int(a)
    b = int(b)
    ```
  MD
  problem.reference_solution = <<~PY
    a, b = input().split()
    a = int(a)
    b = int(b)
    while b != 0:
        a, b = b, a % b
    print(a)
  PY
end

# O segundo caso pega o caso especial de um número dividir o outro, e os vizinhos gigantes
# (MDC 1) derrubam por tempo o laço que testa todos os divisores.
[ "12 18\n", "1000000000000 4\n", "999999999989 999999999988\n" ].each do |input|
  gcd.testcases.find_or_create_by! input: input
end

brackets = contest.problems.find_or_create_by!(title: "Parênteses Balanceados") do |problem|
  problem.position = 9
  problem.difficulty = "hard"
  problem.statement = <<~MD
    Uma sequência de parênteses `()`, colchetes `[]` e chaves `{}` é balanceada quando todo
    símbolo de abertura é fechado pelo símbolo do mesmo tipo, na ordem correta. `([]{})` é
    balanceada; `([)]`, `(()` e `)(` não são. Dada uma sequência, diga se ela é balanceada.

    ## Entrada

    Uma única linha com até 1.000 caracteres, contendo apenas os símbolos `(`, `)`, `[`,
    `]`, `{` e `}`.

    ## Saída

    Uma única linha com `SIM`, se a sequência for balanceada, ou `NAO`, caso contrário.

    ## Exemplo

    Para a entrada

    ```
    ([]{})
    ```

    a saída é

    ```
    SIM
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão: `input()` devolve a linha inteira, já sem a
    quebra de linha. Não peça nada ao usuário.

    ```
    sequencia = input()
    ```
  MD
  problem.reference_solution = <<~PY
    pares = {")": "(", "]": "[", "}": "{"}
    pilha = []
    equilibrada = True
    for simbolo in input():
        if simbolo in "([{":
            pilha.append(simbolo)
        elif not pilha or pilha.pop() != pares[simbolo]:
            equilibrada = False
            break
    print("SIM" if equilibrada and not pilha else "NAO")
  PY
end

# "([)]" pega quem só conta cada tipo, "((" pega quem esquece a pilha que sobra no final,
# e ")(" pega quem só compara totais de abertura e fechamento.
[ "([]{})\n", "([)]\n", "(()\n", ")(\n" ].each do |input|
  brackets.testcases.find_or_create_by! input: input
end

max_sum = contest.problems.find_or_create_by!(title: "Soma Máxima") do |problem|
  problem.position = 10
  problem.difficulty = "hard"
  problem.statement = <<~MD
    Dada uma lista de números inteiros, encontre a maior soma possível de um trecho
    contíguo da lista — elementos consecutivos, com pelo menos um elemento. Na lista
    `2 -1 3 -2 4`, o trecho de maior soma é a lista inteira, que soma 6.

    ## Entrada

    A primeira linha tem um número inteiro N, com 1 ≤ N ≤ 10.000. A segunda linha tem N
    números inteiros entre -100 e 100, separados por espaços.

    ## Saída

    Uma única linha com a maior soma de um trecho contíguo da lista.

    ## Exemplo

    Para a entrada

    ```
    5
    2 -1 3 -2 4
    ```

    a saída é

    ```
    6
    ```

    ## Como ler a entrada

    A entrada chega pronta pela entrada padrão. A primeira chamada de `input()` devolve N;
    a segunda devolve a lista inteira, que `split()` separa pelos espaços. Não peça nada ao
    usuário.

    ```
    n = int(input())
    valores = [int(valor) for valor in input().split()]
    ```
  MD
  problem.reference_solution = <<~PY
    n = int(input())
    valores = [int(valor) for valor in input().split()]
    melhor = atual = valores[0]
    for valor in valores[1:]:
        atual = max(valor, atual + valor)
        melhor = max(melhor, atual)
    print(melhor)
  PY
end

# A entrada grande é gerada por fórmula, não por sorteio: o seed precisa produzir sempre os
# mesmos bytes para continuar idempotente. Os 10.000 valores derrubam por tempo quem soma
# cada trecho do zero, e a lista toda negativa pega quem começa a soma máxima em zero.
large_input = "10000\n#{(1..10_000).map { |i| i * i % 199 - 99 }.join(" ")}\n"

[ "5\n2 -1 3 -2 4\n", "4\n-5 -2 -8 -3\n", large_input ].each do |input|
  max_sum.testcases.find_or_create_by! input: input
end
