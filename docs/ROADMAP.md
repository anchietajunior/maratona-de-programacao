# ROADMAP

Memória física do progresso. Qualquer agente que entrar no projeto lê este arquivo para
saber exatamente onde a implementação parou.

**Ao concluir uma task, marque o checkbox e atualize "Onde estamos" na mesma edição.**
Um roadmap desatualizado é pior que nenhum — ele mente com confiança.

Este arquivo diz *o que falta e em que ordem*. Não repete decisões (`docs/adr/`), nem
vocabulário (`CONTEXT.md`), nem regras de como construir (`docs/rules/`).

---

## Onde estamos

**Fase 10 — Preparação do evento. Não sobrou task de código.** As Fases 0 a 9 estão
fechadas; o que falta não se escreve, se ensaia — calibrar limites com os problemas reais,
rodar offline na máquina do laboratório e cadastrar os 10 problemas.

**O caminho inteiro existe.** A Comissão cadastra um Problema, informa **só a entrada** de
cada Caso de Teste e a saída esperada nasce da Solução de Referência; abre a Competição; a
Equipe lê o Enunciado, cola código, recebe o Veredicto na tela sem recarregar nada,
pergunta e é respondida; a Comissão acompanha submissões, responde, registra Balões,
encerra e divulga a Classificação. 131 testes, `bin/rubocop` limpo.

**As duas perguntas de regulamento foram respondidas** e as duas confirmaram o que os ADRs
já assumiam: 3 horas contadas do início real, e submissão ilimitada mesmo depois do AC —
o que apagou a antiga task 7.4 e criou a regra de que WA posterior ao AC não penaliza.

**Dois bugs de encoding apareceram, ambos da mesma família e ambos invisíveis em
desenvolvimento com texto ASCII.** O primeiro, na Fase 2: a saída esperada volta do MySQL
como `ASCII-8BIT` e o Ruby a considera diferente de uma UTF-8 com os mesmos bytes — daria
WA em todo Problema com acento na saída. O segundo, na Fase 3: `File.write` transcodifica,
e uma **entrada** com acento estourava antes de o contêiner subir. O Juiz agora compara
bytes e escreve bytes. Vale desconfiar de qualquer terceiro ponto onde texto do banco
encontre o sistema de arquivos.

**`bin/ci` passa inteiro** — rubocop, bundler-audit, importmap audit, brakeman, testes e
seeds. O Brakeman acusava "Command Injection" em `Judge#run_container` desde antes deste
trabalho. Atualizar dependências não resolveria: o aviso é do nosso código, não de gem. O
que resolveu foi separar as duas coisas que ele confundia — o script do contêiner virou
literal congelado (`Judge::SCRIPT`), com os limites atravessando como variáveis de
ambiente, e as interpolações que sobraram são argumentos de `execve`, que nunca veem um
shell. Como o Brakeman não distingue a forma argv, a exceção está registrada com a análise
inteira em `config/brakeman.ignore`. **Ao mexer em `run_container`, refaça a análise** em
vez de regerar a impressão digital.

Próxima task: `10.1 — Calibrar TIME_LIMIT` — os 10 problemas (10.5) já estão nos seeds.

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
- [x] **1.5 Seeds** — as duas comissões, as 15 equipes do Art. 21 e a Competição ainda não
      iniciada. Idempotentes: sobrevivem ao `db:seed:replant` no ambiente de teste, que é o
      passo do `bin/ci`
  - A senha sai de `SEED_PASSWORD`, com `12345` de padrão — na véspera do evento as
    credenciais reais entram por aí, sem editar o arquivo
  - ~~Sem Problemas nem Casos de Teste~~ — **mudou.** Os Problemas passaram a morar nos
    seeds, começando pelo Palíndromo na posição 1. Só a *entrada* de cada Caso de Teste é
    escrita ali; a saída esperada continua sendo gerada pela Solução de Referência
    (ADR-0003), o que faz o seed exigir Docker — inclusive no `db:seed:replant` do
    `bin/ci`. O custo é aceitável porque os testes já exigiam, mas na máquina do
    laboratório a imagem `python:3.12-slim` vira pré-requisito para *seedar*, não só para
    julgar (ver 10.3)

---

## Fase 2 — Julgamento ponta a ponta

Conecta o `Judge` (que já funciona) ao ciclo de vida de uma `Submission`.

- [x] **2.1 `Submission::Judgeable`** — `judge_later` (after_create_commit) e `judge_now`,
      que roda o `Judge` e grava o veredicto
  - Os Casos de Teste chegam ao Juiz por `Problem#judging_cases`, no modelo que os possui.
    A 3.4 reusa o mesmo método para validar a Solução de Referência
  - **A comparação do Juiz passou a ser por bytes** (`actual.b == expected.b`). A saída
    esperada vem de coluna binária e o MySQL a devolve como `ASCII-8BIT`; em Ruby, uma
    string binária e uma UTF-8 com os mesmos bytes **não são iguais**. Sem isso, todo
    Problema com acento na saída daria WA — é o raciocínio do ADR-0003 aplicado ao Ruby
- [x] **2.2 `Submission::JudgeJob`** — job raso, só delega para `judge_now`
- [x] **2.3 Solid Queue rodando** — desenvolvimento ganhou o banco `queue` separado, como
      produção já tinha, e `jobs: bin/jobs` entrou no `Procfile.dev`. Conferido ponta a
      ponta: a submissão nasce pendente e o worker grava `AC` sozinho
- [x] **2.4 Testes** — a Submissão entra na fila sozinha, o job grava o veredicto, e a
      saída acentuada vinda da coluna binária é julgada pelos bytes
  - A matriz dos sete veredictos **continua no `test/judge_test.rb`**, onde já está.
    Repeti-la pela `Submission` custaria ~40s de contêiner (o TLE espera o limite inteiro,
    o MLE aloca 256MB) sem exercitar nada que a ponte acrescente
  - `ActiveJob::TestHelper` não vem incluído no `ActiveSupport::TestCase` deste app; quem
    precisa de `assert_enqueued_with` inclui na própria classe de teste

---

## Fase 3 — Cadastro de Problemas (staff)

**Prioridade alta apesar de ser tela de staff.** Assim que existir, a comissão técnica
começa a preparar os 10 problemas em paralelo com o resto da construção — e preparar
problemas é o caminho crítico real do evento, não o software.

- [x] **3.1 `Staff::ProblemsController`** — CRUD, enunciado em Markdown (kramdown). A
      `position` é atribuída sozinha na criação: a Comissão não digita numeração
  - O Markdown passa por `sanitize` com uma lista de tags fechada (`ApplicationHelper`).
    `html_safe` cru resolveria igual e acenderia o Brakeman sem necessidade
- [x] **3.2 Cadastro de Testcase** — a comissão informa **só a entrada**. `testcase_params`
      permite apenas `:input`, então saída esperada não tem por onde entrar
- [x] **3.3 Geração da saída esperada** — `Testcase::Generated` roda a `reference_solution`
      pelo novo `Judge#run`, que devolve o stdout em vez de um Veredicto (ADR-0003)
  - Aqui apareceu o segundo bug de encoding da série: `File.write` **transcodifica**, e uma
    entrada com acento vinda de coluna binária estourava `Encoding::UndefinedConversionError`
    antes mesmo de o contêiner subir. `Judge#prepare` agora escreve bytes (`binwrite`) —
    conserta a geração **e** o julgamento, que compartilham o método
- [x] **3.4 Validação ao salvar** — `Problem::Verifiable` recusa trocar a
      `reference_solution` se ela não passar nos Casos de Teste já cadastrados
  - Só roda contêiner quando a referência **mudou** e já existem Casos de Teste: editar o
    título não custa 2s de Docker
- [x] **3.5 Testes** — geração de saída, recusa da entrada que quebra a referência, recusa
      da referência que falha, e a saída esperada mandada de fora sendo sobrescrita
  - O teste 2.4 da saída acentuada foi reescrito: ele digitava `expected_output` na mão, o
    que a 3.3 tornou impossível. Agora ele passa pelo caminho de verdade

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

- [x] **5.1 Lista de Problemas** — título e Nível de Dificuldade, ordem livre (Art. 19).
      Cada card já diz se a Equipe resolveu ou quantas vezes tentou
- [x] **5.2 Leitura do Enunciado** — Markdown renderizado. O HTML sai do kramdown, então o
      estilo dessas tags vive numa classe `.statement` no CSS, com os tokens do design.md
- [x] **5.3 Submeter** — colar código numa caixa de texto e enviar
- [x] **5.4 Retorno da submissão** — **rung 2 do `docs/rules/hotwire.md`**, não stream na
      mão: `Submission::Broadcastable` faz `broadcasts_refreshes_to` para a própria Equipe e
      para `:staff_submissions`, e a página se remorfa sozinha quando o Veredicto grava
  - A Equipe assina `Current.user` e `:announcements` no `_team_nav`; o refresh não carrega
    dado nenhum, cada navegador rebusca a **própria** página (Art. 34)

> **M1 atingido: primeiro teste manual.** Subir o app, logar como equipe, ler um problema,
> submeter uma solução correta e uma errada, ver os veredictos certos aparecerem.

---

## Fase 6 — Pontuação e placar

O coração das regras. É onde o evento ganha ou perde credibilidade.

- [x] **6.1 `User::Scoreable`** — `score` e `total_time` **derivados** das submissões,
      nunca acumulados em coluna (ADR-0010)
  - `solutions` é a **primeira** Submissão aceita de cada Problema. Como o Art. 27 deixa
    submeter depois do AC, sem esse `uniq` um segundo AC pontuaria de novo
- [x] **6.2 Penalidade retroativa** — 10 min por tentativa errada **só** em Problema
      depois resolvido (Art. 31-III)
  - Só conta tentativa errada **anterior** ao AC. Como o Art. 27 permite submeter depois de
    resolver, um WA posterior ao AC não penaliza — a penalidade paga o caminho até a
    solução, e esse caminho terminou
  - Submissão ainda na fila (`verdict` nulo) não é tentativa errada: `incorrect?` exige
    julgada **e** não aceita
- [x] **6.3 Placar Individual** — a equipe vê resolvidos, tentativas, tempo e pontuação;
      nada de outra equipe (Art. 34)
- [x] **6.4 Standings (staff)** — `User.standings`, com os três critérios do Art. 29-33
  - O terceiro critério é o Problema mais difícil resolvido e, entre iguais, o mais cedo. A
    chave termina no `nickname` só para que empate absoluto não saia em ordem sorteada — o
    regulamento não vai até esse nível
- [x] **6.5 Testes de borda** — tudo-ou-nada, penalidade só em problema resolvido, WA depois
      do AC não penaliza nem pontua de novo, segundo AC não pontua duas vezes, submissão na
      fila não penaliza, e os dois desempates

---

## Fase 7 — Ciclo da competição

- [x] **7.1 Iniciar e encerrar** — `resource :start` e `resource :closure` sob `/staff`,
      cada mudança de estado com o seu recurso. O relógio é relativo ao início real e a
      Competição dura 3 horas contadas dele (ADR-0008, confirmado pela coordenação)
  - `Contest#start` é idempotente de propósito: um segundo clique no botão não pode
    reposicionar o marco zero no meio da prova
  - `deadline` é o menor entre `started_at + 3h` e o `ended_at` do encerramento manual, o
    que faz a Competição terminar sozinha se ninguém apertar nada
- [x] **7.2 Bloqueio fora da janela** — validação em `Submission` e em `Clarification`. É o
      **único** bloqueio de submissão que existe: dentro da janela o Art. 27 não impõe
      limite nenhum
  - Aqui o `create!` da regra de controllers deu lugar a `save` + alerta: submeter no
    segundo em que a Competição fecha não é bug de formulário nosso, é a corrida real
- [x] **7.3 Contagem visível** — `countdown_controller.js` (rung 5), decrementando os
      segundos que o servidor renderizou em vez de comparar relógios — o da máquina do
      laboratório não é confiável
  - ~~**7.4 Problema aceito fica fechado**~~ — não existe. A coordenação confirmou o Art. 27
    à risca: a equipe submete quantas vezes quiser, inclusive depois do AC

---

## Fase 8 — Esclarecimentos

- [x] **8.1 `Clarification`** — a equipe pergunta na página do Problema, durante a
      competição (Art. 35), e acompanha em `/clarifications`
- [x] **8.2 `resource :answer`** — a Resposta é um registro com autor e instante, não uma
      coluna na pergunta. Responder duas vezes é recusado com alerta, não com 500
- [x] **8.3 Broadcast** — `collective: true` manda a Resposta ao mural `:announcements`, que
      toda Equipe assina
  - A autoria da pergunta **não** aparece no mural: o que o Art. 36 torna coletivo é o
    assunto, não quem perguntou

---

## Fase 9 — Operação → **M2**

- [x] **9.1 Submissões e código (staff)** — `/staff/submissions`, com o código de cada
      Submissão e o Veredicto, atualizando sozinho pelo stream `:staff_submissions`
- [x] **9.2 Balões** — `Delivery` (equipe, problema, quem entregou), com índice único no par
  - Virou `resources :deliveries` no plural, não `resource :delivery`: o Balão em si não é
    registro nenhum — ele é derivado do AC — e quem tem id é a entrega, que precisa dele
    para ser desfeita
- [x] **9.3 Encerrar sessão de equipe** — `Staff::SessionsController#destroy`, no painel, ao
      lado de cada Equipe conectada (exigido pelo ADR-0009)
- [x] **9.4 Publicação da Classificação** — `resource :publication`, reversível. Antes dela,
      `/standings` manda a Equipe de volta ao Placar Individual (Art. 28)
- [x] **9.5 Gerenciar equipes (staff)** — `/staff/users`, nome e senha de cada Equipe.
      Senha em branco mantém a atual (comportamento do `has_secure_password`); o escopo
      `User.competing` deixa staff fora do alcance da tela por construção, e o apelido
      não muda — ele é a credencial (ADR-0011)
  - O estado ficou em `contests.published_at`, não numa tabela `publications`: é o terceiro
    instante do ciclo da Competição, e mora junto de `started_at` e `ended_at`

> **M2 atingido.** Dá para simular a competição inteira: cadastrar problemas, abrir,
> submeter de várias equipes, acompanhar, encerrar, publicar.

---

## Fase 10 — Preparação do evento → **M3**

Nada aqui é código. É o que costuma explodir por ficar para a véspera.

> **Ferramenta de ensaio:** o painel tem **Reiniciar competição** (`DELETE /staff/start`),
> que zera o relógio e apaga a rodada — Submissões, Esclarecimentos e Balões — mantendo
> Problemas e Casos de Teste. O trabalho sai em segundo plano (`Contest::RestartJob`), então
> o botão só vale com o worker de pé: `bin/dev` sobe um, `bin/jobs` sobe sozinho.
> Apagar não é opção: o Tempo Acumulado conta do marco zero, e
> Submissão anterior a um marco zero novo sairia com tempo negativo. É o que permite rodar
> 10.3, 10.4 e 10.6 mais de uma vez. **Na noite do evento esse botão apaga a prova** — vale
> decidir antes se ele fica visível em produção.

- [ ] **10.1 Calibrar `TIME_LIMIT`** — hoje 5s é chute; medir com as
      `reference_solution` reais dos 10 problemas
- [ ] **10.2 Calibrar expiração de sessão** — curto demais desloga durante a prova, longo
      demais trava a equipe fora
- [ ] **10.3 Ensaio offline** — na máquina do laboratório, **com a rede desligada**:
      imagem `python:3.12-slim` já presente, binário do Tailwind já baixado, assets locais
      (ADR-0005)
- [ ] **10.4 Teste de carga** — 15 equipes submetendo ao mesmo tempo no minuto final
- [x] **10.5 Cadastrar os 10 problemas reais** com casos de teste validados — moram nos
      seeds (1.5), fechando os 180 pontos do Art. 19: 4 fáceis (Palíndromo, Par ou Ímpar,
      Contagem de Vogais, Média das Notas), 4 médios (Fibonacci, Número Primo, Anagramas,
      Máximo Divisor Comum) e 2 difíceis (Parênteses Balanceados, Soma Máxima)
  - Cada Problema tem um caso por erro clássico, comentado no seed — e os médios/difíceis
    têm um caso grande que derruba a solução ingênua por tempo (recursão no Fibonacci,
    laço até N no Primo, subtração no MDC, soma O(n²) na Soma Máxima), o material que a
    10.1 precisa para calibrar o `TIME_LIMIT`
- [ ] **10.6 Ensaio geral com pessoas** — algumas equipes reais, uma hora, antes do dia

---

## Bloqueios abertos

Nenhum. As três perguntas foram respondidas.

- **Art. 20** — a Competição dura **3 horas contadas do início real**, não até um horário
  fixo. Começou 19h20, encerra 22h20. Confirmado pela coordenação; era a suposição do
  ADR-0008, que agora é regra. *7.1 liberada.*
- **Art. 27** — **submissão ilimitada, à risca**: depois do AC a equipe ainda pode submeter
  no mesmo Problema. O Problema não fecha, e a tarefa 7.4 deixou de existir. Confirmado
  pela coordenação; é o que o ADR-0007 já dizia.
- **`User` × `Team`** — a Equipe é o `User` com `staff: false`, sem tabela `teams`
  ([ADR-0011](adr/0011-equipe-e-o-user.md)). 1.1 e 1.2 estão liberadas.

---

## Fora de escopo

Registrado para ninguém reabrir por engano:

- **Detecção de cola** — coberta administrativamente: um computador por equipe (Art. 21),
  sessão única, sala supervisionada, desclassificação prevista
- **Editor de código no navegador** — Art. 22 exige PyCharm; a equipe cola o código pronto
- **Java** — Art. 22 aceita apenas Python 3
- **Upload de arquivo, imagens em enunciado, e-mail, deploy remoto** — Active Storage,
  Action Mailer e Kamal foram removidos do app
