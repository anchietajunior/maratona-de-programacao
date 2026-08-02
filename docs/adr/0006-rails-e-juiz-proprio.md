# Rails 8 e MySQL, com juiz próprio em vez de DOMjudge

O sistema é construído em Rails 8 sobre MySQL, com juiz próprio. Turbo Streams entrega as
telas ao vivo e Solid Queue entrega a fila de julgamento sem nenhuma infraestrutura
adicional na máquina do laboratório — sem Redis, sem worker externo, sem servidor de
websocket. MySQL porque a universidade já o opera e sabe manter.

## O DOMjudge foi reavaliado, não ignorado

Uma versão anterior desta decisão rejeitava o DOMjudge alegando que "o modelo dele é o
oposto do nosso". Quando o regulamento chegou, essa justificativa evaporou: o regulamento
**é** ICPC, e o DOMjudge roda a final mundial do ICPC. Ele entrega de fábrica os sete
veredictos do Art. 26, submissões ilimitadas, penalidade configurável, placar ocultável,
esclarecimentos e controle de balões — e roda em MySQL.

Reavaliado com a justificativa correta, decidimos ainda assim construir:

- **É um sistema para o curso de Sistemas de Informação.** O software tem valor próprio:
  fica em português, com a identidade da instituição, e é mantido pelo curso nas próximas
  edições.
- **O Art. 22 encolheu o escopo pela metade.** Com PyCharm obrigatório, não há editor,
  realce de sintaxe, rascunho nem Java. Sobrou submissão, julgamento, placar e
  esclarecimentos — construível no prazo.
- **O fluxo de submissão diverge.** O DOMjudge é construído em torno de upload de arquivo;
  aqui a equipe cola o código numa caixa de texto.
- **Pontos por Nível de Dificuldade** (10/20/30, Art. 19) não é o modelo padrão do ICPC,
  que conta problemas resolvidos. Exigiria configuração ou adaptação de qualquer forma.

## A arquitetura que foi explicitamente rejeitada

**Rails como fachada sobre o DOMjudge via API**, com o DOMjudge como motor de julgamento.
Parece o melhor dos dois mundos e é o pior: exige aprender o DOMjudge *e* escrever o Rails,
mantém dois modelos de dados em sincronia, e coloca dois sistemas para depurar às 20h30 do
dia da Competição — um deles em PHP que ninguém aqui escreveu. O ganho seria ter os botões
em português.

Se algum dia o custo de manter o juiz próprio superar o de operar o DOMjudge, a migração
correta é adotá-lo inteiro, não pendurá-lo atrás de uma fachada.
