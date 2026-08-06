# Maratona

Sistema de julgamento automático da Maratona de Programação do curso de Sistemas de
Informação da UniRios. Equipes resolvem problemas algorítmicos em Python 3 durante três
horas; o sistema julga as submissões e mantém o placar, que só é divulgado na premiação.

O Regulamento da 7ª Maratona (`docs/regulamento.pdf`) é a autoridade sobre todo este
vocabulário. Onde este glossário divergir do regulamento, o regulamento vence. Os artigos
citados abaixo são a fonte de cada termo.

## Language

### Pessoas

**Equipe**:
A unidade que compete. Dispõe de um único computador fornecido pela organização e de uma
credencial própria, de uso exclusivo — compartilhar credencial é desclassificação
imediata. É a Equipe que submete e que pontua, nunca uma pessoa. (Art. 21)
_Avoid_: Aluno, participante, usuário, competidor

**Comissão Técnica**:
Define os Casos de Teste e responde aos Pedidos de Esclarecimento. (Art. 24, 36)
_Avoid_: Avaliador, juiz, professor

**Comissão Organizadora**:
Apura a Classificação ao término da Competição e a divulga na premiação. (Art. 28)
_Avoid_: Admin, banca

### A competição

**Competição**:
O período de três horas, sem interrupção, durante o qual Equipes podem submeter. Começa
quando a Comissão Organizadora a inicia — esse instante é o marco zero de todo cálculo de
tempo, não o horário de parede. (Art. 20)
_Avoid_: Prova, evento, sessão, maratona

**Sessão**:
O vínculo entre uma Equipe e o computador em que ela está conectada. Cada Equipe tem no
máximo uma ativa por vez, refletindo o computador único do Art. 21. (Art. 21)
_Avoid_: Login, acesso, conexão

**Problema**:
Um dos dez problemas algorítmicos, com Nível de Dificuldade declarado no próprio
enunciado. (Art. 19, 23)
_Avoid_: Questão, exercício, desafio, algoritmo

**Enunciado**:
O texto do Problema, em português, que descreve o que resolver e especifica exatamente o
formato de entrada e de saída. Vive no sistema e é lido na tela — não há caderno impresso.
(Art. 19, 23)
_Avoid_: Descrição, texto, especificação

**Nível de Dificuldade**:
Fácil, Médio ou Difícil — vale respectivamente 10, 20 e 30 pontos. São 4 Fáceis, 4 Médios
e 2 Difíceis, totalizando 180 pontos possíveis. É público desde o início. (Art. 19)
_Avoid_: Peso, categoria, complexidade

**Caso de Teste**:
Um par de entrada e saída esperada, definido previamente pela Comissão Técnica, usado para
verificar uma Submissão. Nenhum é visível às Equipes. (Art. 24)
_Avoid_: Cenário, teste automatizado

**Solução de Referência**:
Uma solução correta do Problema, escrita pela Comissão Técnica. É ela que produz a saída
esperada de cada Caso de Teste — a saída nunca é digitada à mão.
_Avoid_: Gabarito, solução oficial

### Submissão e julgamento

**Submeter**:
Enviar uma solução em Python 3 para julgamento. Pode ser feito quantas vezes a Equipe
quiser durante a Competição, inclusive depois de obter AC — o Problema resolvido **não**
fecha. Fora da janela de três horas não se submete. (Art. 22, 27)
_Avoid_: Entregar, enviar, subir

**Submissão**:
O registro de um Submeter: o código, o instante, e o Veredicto que recebeu.
_Avoid_: Tentativa, envio, entrega

**Veredicto**:
O resultado do julgamento de uma Submissão, sempre um destes sete: (Art. 26)

| Sigla | Significado |
|---|---|
| **AC** | Accepted — a solução está correta. É o único que pontua |
| **WA** | Wrong Answer — a saída não corresponde à esperada |
| **TLE** | Time Limit Exceeded — excedeu o tempo máximo |
| **MLE** | Memory Limit Exceeded — excedeu o limite de memória |
| **RE** | Runtime Error — encerrou de forma inesperada |
| **CE** | Compilation Error — o programa não pôde ser compilado |
| **PE** | Presentation Error — saída correta, formatação inadequada |

_Avoid_: Status, resultado, situação

### Pontuação

**Pontuação**:
A soma dos pontos dos Problemas em que a Equipe obteve AC. Vale o Nível de Dificuldade
cheio, independente de quantas tentativas foram necessárias; Problema sem AC vale zero.
Não existe pontuação parcial — passar em 9 de 10 Casos de Teste pontua igual a passar em
nenhum. (Art. 29, 30)
_Avoid_: Nota, score

**Penalidade**:
Dez minutos somados ao Tempo Acumulado para cada Submissão incorreta em um Problema que a
Equipe **veio a resolver depois**. Tentativas em Problema nunca resolvido não penalizam.
(Art. 31)
_Avoid_: Multa, desconto

**Tempo Acumulado**:
Para cada Problema resolvido, o tempo decorrido desde o início real da Competição até a
Submissão aceita, somado às Penalidades. É o primeiro critério de desempate. (Art. 31, 32)
_Avoid_: Tempo total, cronômetro

**Classificação**:
A ordenação das Equipes por maior Pontuação; empate resolve por menor Tempo Acumulado e,
persistindo, por quem resolveu por último o Problema de maior Nível de Dificuldade. É
apurada ao término e divulgada **exclusivamente na cerimônia de premiação**. (Art. 28-33)
_Avoid_: Ranking, placar geral, resultado

**Placar Individual**:
O que a Equipe vê durante a Competição: apenas as próprias informações — Problemas
resolvidos, tentativas por Problema, Tempo Acumulado e Pontuação. Nenhum dado de outra
Equipe aparece. (Art. 34)
_Avoid_: Scoreboard, dashboard

**Balão**:
Marcador físico entregue à Equipe a cada Problema resolvido. Todos são da **mesma cor**,
justamente para que ninguém deduza o desempenho alheio observando a sala. (Art. 25)
_Avoid_: Troféu, marcador

### Esclarecimentos

**Pedido de Esclarecimento**:
Dúvida sobre o enunciado de um Problema, enviada pela Equipe através do sistema durante a
Competição. (Art. 35)
_Avoid_: Clarification, dúvida, ticket

**Resposta**:
O retorno da Comissão Técnica a um Pedido de Esclarecimento, de um de três tipos: resposta
objetiva, "No comment" (quando responder revelaria parte da solução), ou esclarecimento
enviado a **todas** as Equipes quando o assunto é de interesse coletivo. (Art. 36)
_Avoid_: Réplica, retorno
