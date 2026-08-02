# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Automated judging system for the 7th Programming Marathon of the Information Systems
course at **UniRios** (Centro Universitário do Rio São Francisco).

Teams of students solve 10 algorithmic problems in Python 3 during a single 3-hour
supervised session in a computer lab. The system receives submissions, judges them against
predefined test cases, and keeps the standings hidden until the award ceremony.

**Audience.** Two distinct groups, with very different needs:

- **Teams** (up to 15, one shared computer each) — read problem statements, paste and
  submit Python code, see *only their own* progress, ask for clarifications. They are
  undergraduates under time pressure; the interface must be obvious without training.
- **Staff** (technical and organizing committees) — register problems and test cases,
  monitor submissions, answer clarifications, track balloons, publish final standings.

**Scale is deliberately small.** ~15 teams, one lab, three hours, one machine. Nothing here
needs to scale; it needs to not fail on the night.

**Runs entirely offline** on a lab machine (see ADR-0005). No CDN, no cloud, no internet
dependency at run time.

Stack: Rails 8.1 on Ruby 4.0.3, MySQL, Hotwire (Turbo + Stimulus via importmap, no Node
build step), Tailwind, Propshaft, and the Solid trifecta (cache, queue, cable) on the
database. Submitted code runs in throwaway Docker containers, never in the web process.

## Domain — read this before modeling anything

The competition rules come from a **regulation issued by the coordination**
(`docs/regulamento.pdf`). It is the authority: where any product decision conflicts with
it, the regulation wins. Articles are cited throughout the docs as `Art. NN`.

- **`CONTEXT.md`** — the ubiquitous language, in Portuguese, each term traced to its
  article. Read it before naming anything.
- **`docs/adr/`** — 10 architecture decision records. ADR-0007 explains the ICPC model;
  ADR-0002 is revoked and kept to record why.

### Portuguese domain → English code

The domain is defined in Portuguese by the regulation, but **code is English** (see
Conventions). Use this mapping consistently — do not invent alternatives:

| CONTEXT.md (pt-BR) | Code (en) |
|---|---|
| Equipe | `Team` |
| Competição | `Contest` |
| Problema | `Problem` |
| Enunciado | `statement` |
| Nível de Dificuldade | `difficulty` (easy/medium/hard → 10/20/30 points) |
| Caso de Teste | `Testcase` — one word, to avoid colliding with `ActiveSupport::TestCase` |
| Solução de Referência | `reference_solution` |
| Submeter / Submissão | `Submission` |
| Veredicto | `verdict` (`AC WA PE TLE MLE RE CE`) |
| Pontuação | `score` |
| Penalidade | `penalty` (10 min per wrong try on a *later solved* problem) |
| Tempo Acumulado | `total_time` |
| Classificação | `standings` (staff only until the ceremony) |
| Placar Individual | `scoreboard` (a team's own view) |
| Pedido de Esclarecimento / Resposta | `Clarification` / `answer` |
| Balão | `Balloon` |
| Sessão | `Session` (one active per team, ADR-0009) |

Portuguese stays in `CONTEXT.md`, the ADRs, and everything the user reads on screen.

### Rules that are easy to get wrong

- **Scoring is all-or-nothing.** Only `AC` scores. Passing 9 of 10 test cases scores the
  same as passing none (Art. 30). There is no partial credit.
- **Penalty is retroactive and derived.** A wrong submission only costs 10 minutes if the
  team *later* solves that problem (Art. 31-III). Never accumulate penalty in a column —
  `score` and `total_time` are always computed from the set of submissions (ADR-0010).
- **A team sees its own verdicts, never anyone else's position** (Art. 34). What is secret
  is the *ranking*, not the verdict.
- **The clock is relative to the real start**, not to wall-clock 19:00 (ADR-0008).
- **Output comparison lives in Ruby, never in SQL.** MySQL's `utf8mb4_0900_ai_ci` collation
  answers that `"SIM" = "sim"` and `"e" = "é"` are *true* — verified on this database.
  Expected output must be stored in binary columns (ADR-0003).

## Guardrails — read the rules file for your task first

Engineering practices follow **Basecamp's Fizzy** (github.com/basecamp/fizzy),
adapted to this app. The rules live in `docs/rules/`, one file per area, and they are
binding — when in doubt about how to build something, the answer is in one of these
before it is in your head:

| Task touches... | Read first |
|---|---|
| Where code lives, new classes, jobs, services (there are none) | `docs/rules/architecture.md` |
| Models, concerns, migrations, domain logic | `docs/rules/models.md` |
| Routes, controllers, authorization | `docs/rules/controllers.md` |
| Screens: views, partials, Stimulus, Tailwind | `docs/rules/screens.md` **and `docs/design.md`** |
| Reactivity: live updates, Turbo Frames/Streams, broadcasts | `docs/rules/hotwire.md` |
| Any Ruby (conditionals, method ordering, visibility, bangs) | `docs/rules/style.md` |
| Tests and fixtures | `docs/rules/testing.md` |

**`docs/design.md` is the design authority for all screens** — typography, colors,
spacing, radii, components, breakpoints. When working on anything the user sees, use
its tokens and follow its do's/don'ts; never invent visual values.

## Conventions

### Language

**All code is English** — classes, methods, variables, tables, columns, migrations, test
names, comments, commit messages. Portuguese appears *only* in what the user sees: view
copy, flash messages, validation messages, i18n locale files, seed content.

Use `config/locales/pt-BR.yml` for user-facing strings rather than hardcoding Portuguese
in views.

### Comments

Minimal. A comment says **what** a class or method does — never why, never how.

The *why* belongs in `docs/adr/`, not in the source. When a decision needs justification,
write or cite an ADR and reference it by number if the code would otherwise look arbitrary.

```ruby
# Runs submitted code against a problem's test cases and returns a verdict.
class Judge
```

Do not narrate the implementation, restate the code in prose, or leave commented-out code.

### Types

**RBS inline signatures on every method**, using the `#:` comment syntax, with one
exception: **controller actions are not annotated** (they take no arguments and return no
meaningful value).

```ruby
# rbs_inline: enabled

class Judge
  #: (String, Array[Hash[Symbol, String]]) -> Result
  def judge(code, cases)
  end

  private

  #: (String, String) -> String
  def compare(actual, expected)
  end
end
```

Each annotated file needs the `# rbs_inline: enabled` magic comment at the top.

Signatures in `sig/` are **generated** — never edit them by hand. Regenerate after changing
annotations:

```bash
bundle exec rbs-inline --output=sig lib/ app/     # regenerate
bundle exec rbs -I sig validate                   # check they are well-formed
```

Generate from `lib/` and `app/` only, not `test/`. Test annotations are still written (they
document the helpers), but `rbs validate` cannot resolve `ActiveSupport::TestCase` without
pulling in RBS for all of Rails via `rbs collection` — not worth the weight here.

RuboCop's `Layout/LeadingCommentSpace` would rewrite `#:` into `# :` and silently break
every annotation. `.rubocop.yml` sets `AllowRBSInlineAnnotation: true` to prevent this —
do not remove it.

## Commands

**Always run Ruby through mise.** The toolchain is pinned to Ruby 4.0.3 by `.ruby-version`
and resolved by mise — never invoke a system Ruby or another version manager. In an
activated shell `ruby`, `bundle` and `bin/*` already resolve correctly; from a
non-activated context, prefix with `mise exec --`:

```bash
mise current              # Confirm: should report ruby 4.0.3
mise exec -- bin/rails test
```

```bash
bin/setup            # Install gems, prepare DB, start dev server (--skip-server to skip)
bin/dev              # Run app: Rails server + Tailwind watcher (Procfile.dev)
bin/rails test       # Run all tests
bin/rails test test/judge_test.rb                 # Run one test file
bin/rails test test/judge_test.rb:12              # Run one test by line
bin/rubocop          # Lint (rubocop-rails-omakase style)
bin/ci               # Full CI pipeline: rubocop, bundler-audit, importmap audit, brakeman, tests
```

There are no system tests — Capybara and Selenium were removed as unused.

`test/judge_test.rb` needs **Docker running** and the `python:3.12-slim` image present; it
takes ~5s because it starts real containers.

## Database

MySQL via mysql2. Development connects to `127.0.0.1:3306` as `root`/`12345` (override host
with `DB_HOST`). Databases: `maratona_development` / `maratona_test`. In production,
cache/queue/cable each get their own database (see `config/database.yml`); their schemas
live in `db/*_schema.rb` with migrations under `db/{cache,queue,cable}_migrate`.

Default collation is `utf8mb4_0900_ai_ci`, which is case- and accent-insensitive. Columns
holding test case input and expected output must be **binary** so the database never gets a
say in string equality.

## Judging

`lib/judge.rb` is autoloaded (`config.autoload_lib`) and runs independently of Rails —
it takes code plus test cases and returns one of the seven verdicts. It shells out to
`docker run` with no network, a read-only filesystem, a pid limit, and CPU/memory/time
caps. Expected output never enters the container, because submitted code could read it.

## Notes

- Active Storage, Action Mailer, Action Mailbox, Action Text, Kamal, Thruster and jbuilder
  are all removed — this app has no uploads, no email, and no deploy target.
- Problem statements are Markdown, rendered with `kramdown` (pure Ruby: no native
  extension to compile on an offline lab machine).
- CI is defined in `config/ci.rb` (Rails `CI.run` DSL) — it treats Brakeman warnings and
  seed failures as errors, and seeds must survive `db:seed:replant` in the test env.
- JavaScript uses import maps (`config/importmap.rb`); pin new JS deps with
  `bin/importmap pin <pkg>` rather than adding a JS build step.
- Stimulus controllers go in `app/javascript/controllers/`; Tailwind source is
  `app/assets/tailwind/application.css` (compiled output in `app/assets/builds/` is
  generated, don't edit).
- Tailwind's standalone binary must be downloaded **before** the event — it is the kind of
  thing that works in development and breaks on an offline lab machine (ADR-0005).
