# Uma Sessão ativa por Equipe, com login novo bloqueado

Cada Equipe pode ter no máximo uma Sessão ativa. Enquanto ela existir, uma tentativa de
login com a mesma credencial em outro computador é **recusada**. Isso reflete o Art. 21 —
um computador por equipe, credencial de uso exclusivo, compartilhamento sob pena de
desclassificação — e faz o sistema recusar o uso indevido em vez de apenas registrá-lo.

Consideramos derrubar a Sessão anterior em favor da nova, que nunca tranca ninguém do lado
de fora. Rejeitamos porque com ela o sistema aceita silenciosamente dois computadores se
revezando, que é exatamente o comportamento que o Art. 21 proíbe.

## Consequências obrigatórias

Bloquear cria um modo de falha que derrubar não tem: **a Equipe cujo navegador travou fica
trancada fora da própria prova.** Máquina reiniciada, aba fechada, browser congelado — a
Sessão anterior continua "ativa" e a credencial não entra mais. Duas medidas tornam isso
gerenciável, e nenhuma é opcional:

1. **A Sessão expira por inatividade.** Cada requisição carimba o instante da última
   atividade; passados poucos minutos sem nenhuma, a Sessão deixa de bloquear novo login.
   Não é heartbeat — é um timestamp atualizado no tráfego que já existe. Isso resolve
   sozinho a grande maioria dos casos, sem ninguém intervir.
   O cookie anterior continua válido: quem nunca saiu não é deslogado por ficar pensando.

2. **A Comissão consegue encerrar a Sessão de uma Equipe.** Um botão na listagem de
   Equipes, para o caso que a expiração não cobre — a Equipe precisa trocar de máquina
   agora e não pode esperar. Sem isso, o único recurso seria mexer no banco durante a
   Competição.

O tempo de expiração precisa ser calibrado antes do evento: curto demais e a Equipe é
deslogada durante a prova, longo demais e o travamento dura o suficiente para custar
pontos. Poucos minutos é o ponto de partida, não a resposta final.
