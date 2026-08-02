# Model rules

Source: Basecamp's Fizzy. Read `docs/rules/architecture.md` first; read `CONTEXT.md`
before naming anything (Portuguese domain → English code mapping is in `CLAUDE.md`).

## Concerns are the unit of model organization

A model is a short core (associations, scopes, a handful of methods) plus concerns,
each capturing **one trait**, named as an adjective/capability: `Closeable`,
`Judgeable`, `Scoreable`, `Answerable`. They live in `app/models/<model>/` and are
included in one alphabetized statement:

```ruby
class Submission < ApplicationRecord
  include Judgeable, Scoreable
end
```

A concern owns everything about its trait: associations, scopes, predicates, the
state-changing method, and the callbacks that keep it consistent. See Fizzy's
`Card::Closeable` for the canonical shape.

Extract a concern when a trait is coherent, not when a file is long. Never share a
concern between models just because the code looks similar.

## State is a record, not a boolean

When something *happens* to a record, model it as an associated record, not a flag
column. Fizzy closes cards by creating a `Closure`, not by setting `closed: true`:

```ruby
has_one :closure, dependent: :destroy
scope :closed, -> { joins(:closure) }
scope :open,   -> { where.missing(:closure) }

def close(user: Current.user)
  unless closed?
    transaction do
      create_closure! user: user
      track_event :closed
    end
  end
end
```

Apply the same shape here: a balloon delivery, a clarification answer, a session
termination are records with `created_at` and authorship — you get *who* and *when*
for free, and deleting the record is the undo.

**Never store what must be derived.** `score` and `total_time` are computed from the
set of submissions every time (ADR-0010) — no counter columns, no cached penalty.

## Intention-revealing API

State changes are named methods (`close`, `reopen`, `judge_now`), never naked
`update` calls from outside the model. Multi-step changes wrap in `transaction`.
Bang (`!`) only when a non-bang counterpart exists — not to flag danger; inside
models and controllers prefer `create!`/`update!` so failures are loud.

## Defaults and scopes

- Defaults from context via lambdas: `belongs_to :user, default: -> { Current.user }`.
- Scopes get real names: `chronologically`, `reverse_chronologically`, `accepted`,
  `pending` — not `by_date_asc`.
- Override `to_param` when the URL should carry a domain identifier (Fizzy uses
  `card.number`; a problem's letter/position is our equivalent).

## Callbacks

Callbacks are fine for keeping the model's own world consistent (assign a number,
touch a parent, enqueue `_later` jobs after commit). They must not reach into other
domains — that's what the explicit method + transaction is for.

## Hard domain constraints (from CLAUDE.md — re-read them)

- Scoring is all-or-nothing; penalty is retroactive and derived (Art. 30/31, ADR-0010).
- Test case input/expected output live in **binary columns**; string comparison
  happens in Ruby, never in SQL (ADR-0003 — MySQL collation is accent/case-insensitive).
- Every method gets an RBS inline signature (`#:`), per CLAUDE.md → Types.
