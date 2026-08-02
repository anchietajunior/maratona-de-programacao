# Comparação exata, com a saída esperada gerada pela Solução de Referência

A saída da Equipe é comparada byte a byte com a saída esperada do Caso de Teste. Para que
isso seja seguro, a Comissão Técnica **não digita** a saída esperada: cadastra a entrada e
uma Solução de Referência, e o sistema executa a referência para produzir a saída.

A alternativa era aparar espaços antes de comparar. Rejeitamos porque comparação exata só
é frágil quando a saída esperada vem da memória de um humano — aqui ela vem de um `print()`
real, então a quebra de linha final está sempre correta por construção.

## A dupla comparação: WA contra PE

O Art. 26 do regulamento exige distinguir **WA** (saída errada) de **PE** (saída correta,
formatação inadequada). Isso define o algoritmo de julgamento:

```
saída == esperado                    → AC
senão, normalizando espaços, igual   → PE
senão                                → WA
```

Normalizar aqui é aparar espaços no fim de cada linha e linhas vazias no fim da saída — o
que a comparação exata recusa. Uma equipe que imprime `"SIM "` em vez de `"SIM"` recebe PE
e sabe que errou formatação, não algoritmo.

Nenhum dos dois pontua (Art. 30 — só AC), e ambos geram Penalidade se o Problema vier a
ser resolvido depois (Art. 31). A diferença é puramente diagnóstica — mas é a diferença
entre uma equipe corrigir um espaço e uma equipe reescrever o algoritmo certo.

## Consequências

**Saída esperada digitada à mão não existe no sistema.** Se alguém adicionar um campo para
isso, a comparação exata vira armadilha: `print("SIM")` emite `"SIM\n"`, e quem digitar
`"SIM"` no formulário faz todas as equipes receberem WA naquele Caso.

Salvar um Problema exige rodar a Solução de Referência contra todos os Casos de Teste. O
Problema só entra na Competição se ela passar em todos.

**Atenção ao MySQL.** O collation padrão (`utf8mb4_0900_ai_ci`) é *case* e
*accent-insensitive*: no banco, `'SIM' = 'sim'` é verdadeiro. A comparação acontece em
Ruby, não em SQL, e precisa continuar assim. Entradas e saídas esperadas ficam em colunas
binárias para que o banco nunca seja tentado a opinar sobre igualdade de texto.
