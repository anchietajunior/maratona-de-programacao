# Tempo Acumulado e Pontuação são derivados das Submissões, nunca acumulados

Não existe coluna de penalidade nem de pontuação total mantida incrementalmente. Pontuação
e Tempo Acumulado são calculados a partir do conjunto de Submissões de uma Equipe, sempre
que precisam ser exibidos.

A razão é o Art. 31-III: *tentativas em problemas não resolvidos não geram penalidade*. No
instante em que uma Submissão recebe WA, é **impossível saber** se ela vai penalizar — isso
só se decide se a Equipe vier a resolver aquele Problema depois, o que pode acontecer duas
horas mais tarde ou nunca. Somar dez minutos a um contador no momento do erro produz um
placar errado para todo Problema que a Equipe não conseguir resolver.

## O cálculo

Para cada Problema em que existe uma Submissão com Veredicto AC:

- **Pontos** = valor do Nível de Dificuldade (10, 20 ou 30) — independente de quantas
  tentativas foram necessárias (Art. 19, 29, 30)
- **Tempo** = minutos do início da Competição até a Submissão aceita, mais 10 minutos por
  Submissão anterior àquela no mesmo Problema (Art. 31-I, 31-II)

Problemas sem AC contribuem zero para ambos, quaisquer que sejam as tentativas.

## Consequências

O Tempo Acumulado exibido no Placar Individual (Art. 34) **cresce de forma descontínua**:
uma Equipe com três erros acumulados num Problema carrega zero de penalidade por ele até
acertar, e no momento do AC o número salta trinta minutos além do tempo da submissão. É o
comportamento correto pelo regulamento e vai parecer defeito para quem estiver olhando.
Vale a interface deixar explícito que a penalidade só é cobrada de Problema resolvido.

Derivar em vez de acumular também torna o placar reconstruível: se algo for julgado
errado e precisar ser reprocessado, corrigir os Veredictos basta — não há totais
dessincronizados para consertar.
