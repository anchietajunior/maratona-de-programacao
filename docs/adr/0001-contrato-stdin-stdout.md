# Problemas usam contrato stdin → stdout, não funções com assinatura fixa

O programa da Equipe lê a entrada padrão e imprime na saída padrão; o julgamento compara
texto contra texto. Escolhemos isso em vez de exigir uma função com nome definido
(`eh_palindromo(s)`), que precisaria de um arnês de teste e de um esqueleto de código
pré-definido, enquanto stdin/stdout é o formato de maratona de verdade (ICPC) — e é o que
o Art. 24 pressupõe ao falar em "casos de teste previamente definidos".

O Art. 22 restringe a competição a Python 3, então a portabilidade entre linguagens deixou
de ser argumento. A decisão se mantém pelos demais motivos.

## Consequências

O enunciado de cada Problema precisa especificar o formato de entrada e saída com precisão
absoluta, porque é a única referência que a Equipe tem para acertar a formatação. Um
enunciado vago produz veredicto PE ou WA por motivo errado — e cada tentativa custa dez
minutos de Penalidade (Art. 31).
