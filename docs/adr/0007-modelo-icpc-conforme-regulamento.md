# O regulamento é a autoridade; o modelo é ICPC

O regulamento da 7ª Maratona de Programação, emitido pela coordenação, define as regras da
competição. Onde qualquer decisão de produto conflitar com ele, o regulamento vence — e
várias conflitaram (ver [ADR-0002](./0002-entrega-unica-e-cega.md), revogado por este).

O modelo que ele descreve é o ICPC padrão, artigo por artigo:

- **Equipe** é a unidade que compete, com um computador e uma credencial (Art. 21)
- **Submissões ilimitadas** durante as 3 horas, inclusive depois do AC — o Problema
  resolvido não fecha (Art. 20, 27; confirmado pela coordenação)
- **Sete veredictos**: AC, WA, TLE, MLE, RE, CE, PE (Art. 26)
- **Tudo ou nada**: só AC pontua, sem parcial (Art. 30)
- **Pontos por dificuldade**: 10/20/30, total de 180 (Art. 19)
- **Penalidade** de 10 min por tentativa errada em problema depois resolvido (Art. 31)
- **Placar oculto**: cada equipe vê só o que é seu; a classificação sai na premiação
  (Art. 28, 34)

## A distinção que mais importa

**Veredicto próprio é visível; posição relativa não é.** A equipe sabe se acertou o
Problema 3; não sabe se está em primeiro ou em último. Confundir os dois leva a construir
o sistema errado — e foi exatamente o erro que o ADR-0002 cometeu.

Isso tem consequência de implementação: o Placar Individual (Art. 34) e a Classificação
(Art. 28) são duas visões distintas, e nenhuma consulta da tela da Equipe pode alcançar
dados de outra Equipe. Não é questão de esconder na interface — é de não trazer do banco.

## Consequência sobre o Art. 22

O regulamento exige Python 3 desenvolvido no PyCharm instalado nas máquinas da
organização. Isso retira do sistema o editor de código, o realce de sintaxe, o rascunho, a
execução de teste pela equipe e o suporte a Java — tudo que o pedido original previa. O
sistema web recebe código pronto, julga, e mantém placar e esclarecimentos.
