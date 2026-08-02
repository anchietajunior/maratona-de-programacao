# Código submetido roda em contêiner descartável, nunca no processo web

Toda execução de código de Equipe — e a validação da Solução de Referência — acontece num
contêiner criado para aquela execução e destruído em seguida, sem rede, com limite de CPU,
memória e tempo. O Rails apenas enfileira o trabalho e lê o resultado; nunca invoca
`python` diretamente.

Código submetido é código hostil por definição, mesmo sem má intenção: um `while True` sem
saída derruba o servidor no meio da Competição, e um `open()` curioso lê os Casos de Teste
de todos os Problemas. Sem rede também impede buscar a resposta na internet de dentro da
própria submissão.

## Como o contêiner produz cada Veredicto

O regulamento (Art. 26) exige sete veredictos, e é o executor que distingue a maioria:

| Veredicto | Como é detectado |
|---|---|
| **CE** | `python -m py_compile` falha — erro de sintaxe, antes de rodar qualquer Caso |
| **TLE** | o `timeout` matou o processo |
| **MLE** | o cgroup do contêiner acusou estouro de memória |
| **RE** | o processo saiu com código diferente de zero |
| **AC / PE / WA** | comparação da saída em Ruby, ver [ADR-0003](./0003-saida-esperada-gerada-comparacao-exata.md) |

CE é avaliado uma vez, antes do laço de Casos. Os demais são por Caso, e o primeiro Caso
que não resultar em AC define o Veredicto da Submissão inteira — não há pontuação parcial
(Art. 30), então não há motivo para continuar executando depois da primeira falha.

## Consequências

Como só há Python 3 (Art. 22), o executor usa uma única imagem oficial —
`python:3.12-slim`, sem Dockerfile próprio — e não há etapa de compilação nem a
calibragem de tempo que o Java exigiria. É a peça mais simples que este sistema poderia
ter, e ainda assim a que falha de forma mais cara.

Ela roda e é testada sem subir o Rails, e deve ser construída primeiro.

**Escala: até 15 Equipes.** Um único worker de julgamento processando submissões em série
dá conta, inclusive no pico dos minutos finais — nada de paralelismo, nada de dimensionar
fila. Se o número de Equipes crescer numa próxima edição, o caminho é aumentar workers do
Solid Queue, que é configuração, não reescrita.

Consideramos usar um juiz pronto (Judge0, DOMjudge) — ver
[ADR-0006](./0006-rails-e-juiz-proprio.md). Se um dia a precisão de medição de tempo
importar, o caminho conhecido é trocar o Docker pelo `isolate`, o sandbox usado pela IOI,
que mede tempo de CPU em vez de tempo de parede e parte em milissegundos.
