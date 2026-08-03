# ROADMAP

Memória física do progresso. Qualquer agente que entrar no projeto lê este arquivo para
saber exatamente onde a implementação parou.

**Ao concluir uma task, marque o checkbox e atualize "Onde estamos" na mesma edição.**
Um roadmap desatualizado é pior que nenhum — ele mente com confiança.

Este arquivo diz *o que falta e em que ordem*. Não repete decisões (`docs/adr/`), nem
vocabulário (`CONTEXT.md`), nem regras de como construir (`docs/rules/`).

---

## Onde estamos

**Fase 1 — Esquema e modelos.** Fundação pronta: domínio documentado, regras de
engenharia escritas, juiz funcionando e testado contra Docker.

**A Fase 4 foi antecipada e está fechada.** `users` (`nickname`, `name`, senha, `staff`) e
`sessions` (`last_active_at`), com sessão única por equipe e expiração por inatividade — o
ADR-0009 inteiro. As duas superfícies existem e o login roteia por audiência: equipe cai
em `/scoreboard`, staff em `/staff`. Ambas são cascas — o conteúdo chega nas Fases 3, 5 e
6. Existe também uma página inicial pública (`/`) com link para o regulamento e para o
login, os tokens do `docs/design.md` no tema do Tailwind e o locale `pt-BR`.

**A Equipe é o `User`** — decidido, ver [ADR-0011](adr/0011-equipe-e-o-user.md). Não haverá
tabela `teams`: `staff: false` compete, `staff: true` avalia.

**O esquema do domínio existe e tem modelos.** `contests`, `problems`, `testcases` e
`submissions` criadas e migradas; `testcases.input` e `expected_output` são `blob` sem
collation, conferido no banco. Os quatro modelos existem com associações, escopos e
validações: `Problem` tem o enum de dificuldade e `points` (10/20/30), `to_param` sai da
`position`, e `Submission` conhece os sete veredictos, com `verdict` nulo significando
"ainda não julgada". `Current` já estava pronto desde a Fase 4.

**O universo de fixtures existe.** Uma Competição em andamento (começou há 40 minutos),
quatro equipes, três Problemas — um de cada dificuldade, com Solução de Referência de
verdade — cinco Casos de Teste e cinco Submissões que já contam a história de pontuação
que a Fase 6 vai ter de reproduzir: penalidade que vale, penalidade que não vale, e uma
submissão ainda não julgada.

Próxima task: `1.5 — Seeds`.

---

## Marcos

| | Marco | Significa |
|---|---|---|
| **M1** | Fluxo vertical | Uma equipe loga, lê um problema, submete código e o veredicto é gravado. Prova a arquitetura inteira ponta a ponta. **Primeiro ponto de teste manual.** |
| **M2** | Ensaio completo | Todas as regras do regulamento funcionando. Dá para simular a competição inteira do início ao fim. |
| **M3** | Pronto para o evento | Ensaio na máquina do laboratório, sem internet, com os 10 problemas reais cadastrados. |

---

## Fase 0 — Fundação ✅

- [x] Domínio documentado — `CONTEXT.md` alinhado ao regulamento artigo por artigo
- [x] 10 ADRs registrando as decisões e o porquê
- [x] Regras de engenharia — `docs/rules/`, `docs/design.md`
- [x] `lib/judge.rb` — sete veredictos, 15 testes contra Docker real
- [x] App Rails enxuto (11 frameworks removidos), MySQL 9.7.1, RBS inline + `sig/`
- [x] Página inicial pública, tokens do `docs/design.md` no tema do Tailwind, locale `pt-BR`

---

## Fase 1 — Esquema e modelos

Sem lógica de negócio ainda: tabelas, associações e o mundo de fixtures que todos os
testes vão usar.

- [x] **1.1 Migrations** — `contests`, `problems`, `testcases`, `submissions`. Não há
      `teams`: a Equipe é o `User` (ADR-0011), que já existe
  - ~~`users.name`~~ — feito junto com a Fase 4
  - `testcases.input` e `testcases.expected_output` em colunas **binárias** (ADR-0003)
  - `submissions.code` em `text` com `utf8mb4`
  - `problems.difficulty` como enum (easy/medium/hard); os pontos derivam dela
  - `contests.started_at` / `ended_at` — o relógio é relativo ao início real (ADR-0008)
  - Decidido aqui: `problems.position` (único junto com `contest_id`) é a identidade do
    Problema na Competição, e é de onde o `to_param` sai na 1.2 — `id` não serve, o ensaio
    da 10.6 desloca a numeração
  - `problems.reference_solution` e `testcases.expected_output` nascem `null: false`: pelo
    ADR-0003 a saída é gerada pela referência **antes** de o Testcase existir
  - `submissions.verdict` nulo significa "ainda não julgado" (Fase 2)
- [x] **1.2 Modelos e associações** — núcleo curto, sem concerns ainda. `User.competing`
      (`staff: false`) é o escopo por onde toda consulta de competição passa
  - `Problem::POINTS` é a fonte única do enum `difficulty` e de `points` — 4 fáceis, 4
    médios e 2 difíceis fecham os 180 pontos do Art. 19
  - `Testcase` fica sem validação de presença de propósito: entrada e saída vazias são
    legítimas (problema que não lê nada, problema que não imprime nada); só nulo é
    inválido, e o `null: false` já recusa
  - `Submission#accepted?` e o escopo `accepted` são o que a Fase 6 vai somar; `verdict`
    tem inclusão nos sete veredictos, com nulo permitido
- [x] **1.3 `Current`** — `session` já deriva `user`, conforme `docs/rules/architecture.md`.
      Veio junto com a Fase 4
- [x] **1.4 Fixtures** — um contest, 3-4 equipes com nomes de história, problemas de cada
      dificuldade, testcases. É o universo compartilhado (`docs/rules/testing.md`)
  - As Soluções de Referência são código Python que roda de verdade, e as saídas esperadas
    foram conferidas executando cada uma contra as suas entradas
  - Os instantes das Submissões caem no meio do minuto: o Tempo Acumulado é contado em
    minutos inteiros e não pode depender da ordem em que o Rails carrega os fixtures
  - `turing` tem WA e depois AC no mesmo Problema (penalidade vale), `lovelace` tem WA em
    Problema nunca resolvido (não vale) — o par que a 6.2 precisa
- [ ] **1.5 Seeds** — precisam sobreviver a `db:seed:replant` no ambiente de teste, senão
      `bin/ci` quebra

---

## Fase 2 — Julgamento ponta a ponta

Conecta o `Judge` (que já funciona) ao ciclo de vida de uma `Submission`.

- [ ] **2.1 `Submission::Judgeable`** — `judge_later` (after_create_commit) e `judge_now`,
      que roda o `Judge` e grava o veredicto
- [ ] **2.2 `Submission::JudgeJob`** — job raso, só delega para `judge_now`
- [ ] **2.3 Solid Queue rodando** — worker processando de verdade em desenvolvimento
- [ ] **2.4 Testes** — submissão → veredicto gravado, para cada um dos sete veredictos

---

## Fase 3 — Cadastro de Problemas (staff)

**Prioridade alta apesar de ser tela de staff.** Assim que existir, a comissão técnica
começa a preparar os 10 problemas em paralelo com o resto da construção — e preparar
problemas é o caminho crítico real do evento, não o software.

- [ ] **3.1 `Staff::ProblemsController`** — CRUD, enunciado em Markdown (kramdown)
- [ ] **3.2 Cadastro de Testcase** — a comissão informa **só a entrada**
- [ ] **3.3 Geração da saída esperada** — rodar a `reference_solution` produz o
      `expected_output` (ADR-0003). Saída esperada digitada à mão não existe no sistema
- [ ] **3.4 Validação ao salvar** — o Problem só entra na competição se a
      `reference_solution` passar em todos os seus Testcases
- [ ] **3.5 Testes** — geração de saída, e a recusa de um Problem cuja referência falha

---

## Fase 4 — Autenticação e sessão

- [x] **4.1 `Authentication` concern** + login por credencial (Art. 21) — `nickname`
      (`equipe01`) em vez de e-mail; `users.staff` é a base da autorização. O fluxo de
      recuperação de senha do gerador foi removido: o app não tem Action Mailer
- [x] **4.2 Sessão única por equipe** — `User#signed_in_elsewhere?` recusa o login enquanto
      houver Sessão ativa (ADR-0009). **Staff não tem a restrição**: o Art. 21 fala de
      Equipe, e as comissões usam mais de uma máquina
- [x] **4.3 Expiração por inatividade** — `Session::INACTIVITY_LIMIT` (10 min, calibrar em
      10.2) e `last_active_at` carimbado em `resume_session`. Expirar só **desbloqueia
      novo login**; o cookie anterior continua autenticando, conforme o ADR-0009
  - Só há tráfego autenticado no logout hoje, então o carimbo só será exercitado de
    verdade a partir da Fase 5. O teste de integração do carimbo entra com a primeira tela
    de equipe
- [x] **4.4 Login de staff** — namespace `Staff::` sob `/staff`, protegido por
      `Staff::BaseController#ensure_staff`. Login roteia por audiência: staff vai para
      `/staff`, equipe para `/scoreboard` (`Authentication#home_url_for`)
- [x] **4.5 Testes** — segundo login bloqueado, sessão inativa libera novo login, staff
      loga em duas máquinas, cookie expirado ainda autentica

---

## Fase 5 — Telas da equipe → **M1**

- [ ] **5.1 Lista de Problemas** — título e Nível de Dificuldade, ordem livre (Art. 19)
- [ ] **5.2 Leitura do Enunciado** — Markdown renderizado
- [ ] **5.3 Submeter** — colar código numa caixa de texto e enviar
- [ ] **5.4 Retorno da submissão** — Turbo Stream mostrando o veredicto **da própria
      equipe** (Art. 34)

> **M1 atingido: primeiro teste manual.** Subir o app, logar como equipe, ler um problema,
> submeter uma solução correta e uma errada, ver os veredictos certos aparecerem.

---

## Fase 6 — Pontuação e placar

O coração das regras. É onde o evento ganha ou perde credibilidade.

- [ ] **6.1 `User::Scoreable`** — `score` e `total_time` **derivados** das submissões,
      nunca acumulados em coluna (ADR-0010)
- [ ] **6.2 Penalidade retroativa** — 10 min por tentativa errada **só** em Problema
      depois resolvido (Art. 31-III)
- [ ] **6.3 Placar Individual** — a equipe vê resolvidos, tentativas, tempo e pontuação;
      nada de outra equipe (Art. 34). `ScoreboardsController#show` já existe como casca —
      é onde a equipe cai depois do login; falta todo o conteúdo
- [ ] **6.4 Standings (staff)** — classificação com os três critérios de desempate:
      pontuação → tempo → maior dificuldade resolvida por último (Art. 29-33)
- [ ] **6.5 Testes de borda** — obrigatórios (`docs/rules/testing.md`): tudo-ou-nada,
      penalidade só em problema resolvido, empate resolvido em cada nível

---

## Fase 7 — Ciclo da competição

- [ ] **7.1 Iniciar e encerrar** — a Comissão abre; o relógio é relativo a esse instante
      (ADR-0008) ⚠️ *depende da pergunta 1 abaixo*
- [ ] **7.2 Bloqueio fora da janela** — nada de submeter antes do início ou após o fim
- [ ] **7.3 Contagem visível** — tempo restante na tela da equipe
- [ ] **7.4 Problema aceito fica fechado** ⚠️ *depende da pergunta 2 abaixo*

---

## Fase 8 — Esclarecimentos

- [ ] **8.1 `Clarification`** — a equipe pergunta durante a competição (Art. 35)
- [ ] **8.2 `resource :answer`** — resposta objetiva ou "No comment" (Art. 36)
- [ ] **8.3 Broadcast** — esclarecimento de interesse coletivo vai para todas as equipes

---

## Fase 9 — Operação → **M2**

- [ ] **9.1 Submissões e código (staff)** — ver o que cada equipe entregou
- [ ] **9.2 Balões** — `resource :delivery`, registro com autor e instante
- [ ] **9.3 Encerrar sessão de equipe** — botão para a Comissão (exigido pelo ADR-0009)
- [ ] **9.4 Publicação da Classificação** — visível às equipes só após a premiação
      (Art. 28)

> **M2 atingido.** Dá para simular a competição inteira: cadastrar problemas, abrir,
> submeter de várias equipes, acompanhar, encerrar, publicar.

---

## Fase 10 — Preparação do evento → **M3**

Nada aqui é código. É o que costuma explodir por ficar para a véspera.

- [ ] **10.1 Calibrar `TIME_LIMIT`** — hoje 5s é chute; medir com as
      `reference_solution` reais dos 10 problemas
- [ ] **10.2 Calibrar expiração de sessão** — curto demais desloga durante a prova, longo
      demais trava a equipe fora
- [ ] **10.3 Ensaio offline** — na máquina do laboratório, **com a rede desligada**:
      imagem `python:3.12-slim` já presente, binário do Tailwind já baixado, assets locais
      (ADR-0005)
- [ ] **10.4 Teste de carga** — 15 equipes submetendo ao mesmo tempo no minuto final
- [ ] **10.5 Cadastrar os 10 problemas reais** com casos de teste validados
- [ ] **10.6 Ensaio geral com pessoas** — algumas equipes reais, uma hora, antes do dia

---

## Bloqueios abertos

Duas perguntas para a coordenação. Nenhuma trava as Fases 1-6.

1. **Art. 20** — se a Competição começar 19h20, encerra 22h20 (3h de duração) ou 22h00
   (horário fixo)? Assumido: duração de 3h (ADR-0008). *Bloqueia 7.1.*
2. **Art. 27** — depois de obter AC num Problema, a equipe ainda pode submeter nele?
   Assumido: não, o Problema fecha. *Bloqueia 7.4.*
Resolvido: **`User` × `Team`** — a Equipe é o `User` com `staff: false`, sem tabela
`teams` ([ADR-0011](adr/0011-equipe-e-o-user.md)). 1.1 e 1.2 estão liberadas.

---

## Fora de escopo

Registrado para ninguém reabrir por engano:

- **Detecção de cola** — coberta administrativamente: um computador por equipe (Art. 21),
  sessão única, sala supervisionada, desclassificação prevista
- **Editor de código no navegador** — Art. 22 exige PyCharm; a equipe cola o código pronto
- **Java** — Art. 22 aceita apenas Python 3
- **Upload de arquivo, imagens em enunciado, e-mail, deploy remoto** — Active Storage,
  Action Mailer e Kamal foram removidos do app
