# A Equipe é o `User`; não existe tabela `teams`

Cada Equipe é uma linha em `users`, com uma credencial (`nickname` + senha) e
`staff: false`. Quem avalia é `staff: true`. Não há tabela `teams`, nem associação entre
usuário e equipe.

O regulamento não conhece integrante de equipe. Nos Arts. 19 a 37 não aparecem "aluno",
"membro" ou "participante" — todo sujeito é *a equipe*: a equipe submete, a equipe recebe
balão, a equipe é classificada. O Art. 21 fecha a questão do lado físico: um computador
por equipe, equipamento pessoal vedado, uma credencial de uso exclusivo **da respectiva
equipe**. Dois logins simultâneos da mesma equipe não são proibidos pelo regulamento
porque são impossíveis na sala.

Uma segunda tabela modelaria uma distinção que o evento não tem.

## O que rejeitamos

O modelo do DOMjudge, que é a implementação de referência deste domínio: `Team` tem muitos
`User`, e `user.team` é nulo para júri e admin. Ele precisa disso por duas razões que aqui
não valem — serve competições em que cada integrante tem conta própria, e precisa de
usuários sem equipe para as comissões. A segunda razão o `staff` já resolve; a primeira não
existe sob o Art. 21.

## Consequências obrigatórias

**A linguagem não muda.** `CONTEXT.md` continua correto: na tela, nas mensagens e nos
docs, quem compete é a **Equipe**, e "usuário" segue na lista de termos a evitar. O que
mudou é só o nome da classe. A tabela de tradução em `CLAUDE.md` é a autoridade sobre
isso — ela diz Equipe → `User`.

**`nickname` é credencial, não nome.** `equipe01` identifica o login; a Classificação e a
entrega de Balões precisam exibir o nome da equipe. A migration da task 1.1 acrescenta
`users.name`.

**Usuário de staff carrega associação que nunca usa.** `User` recebe os traços de
pontuação (`Scoreable`), e um usuário da comissão passa a ter `submissions` e `balloons`
que ficarão sempre vazios. É o preço de não ter a segunda tabela, e ele é aceitável em
~15 linhas. Toda consulta de competição passa por um escopo que nomeia a intenção —
`User.competing` — e a Classificação nunca alcança staff.

**O ADR-0009 continua valendo sem alteração.** Uma Sessão ativa por `User` *é* uma Sessão
ativa por Equipe: era isso que ele sempre quis dizer.

**Teto conhecido.** Se a coordenação passar a dar uma conta por integrante, isto vira uma
tabela `teams` e uma coluna `users.team_id` — migration e renomeação, não redesenho. Não
antecipar.
