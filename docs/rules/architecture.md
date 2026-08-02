# Architecture rules

Source: Basecamp's Fizzy (github.com/basecamp/fizzy) — "vanilla Rails is plenty".
These rules decide **where code lives**. Read before adding any new class or file.

## The one big rule

Thin controllers invoking a **rich domain model**. There is no service layer, no
interactor, no command object, no `app/services/`. Complex behavior gets an
intention-revealing method on the model that owns it:

```ruby
# Bad — logic in the controller, or a SubmissionJudgingService
# Good — the controller calls one expressive method:
@submission.judge
```

A plain Ruby object (PORO) in `app/models/` is fine when something isn't backed by a
table (Fizzy's `Signup`, our `Judge::Result`). It is still "the model" — don't treat
POROs as a special artifact with its own folder or naming scheme.

## Where things live

| Kind of code | Location |
|---|---|
| Domain logic (scoring, penalty, verdicts, standings) | `app/models/` — AR models and POROs |
| Rails-independent machinery (container judging) | `lib/` (autoloaded; `lib/judge.rb` must keep working without Rails) |
| HTTP concerns: params, redirects, formats, auth | `app/controllers/` |
| Presentation logic (badges, verdict colors, tag building) | `app/helpers/` |
| Async execution | `app/jobs/` — shallow, see below |
| Per-request global state | `Current` (`ActiveSupport::CurrentAttributes`) |

## Jobs are shallow

A job never contains logic. It delegates to a model method, and the naming pair is
fixed: `_later` enqueues, `_now` does the work synchronously.

```ruby
module Submission::Judgeable
  extend ActiveSupport::Concern

  included do
    after_create_commit :judge_later
  end

  def judge_later
    Submission::JudgeJob.perform_later(self)
  end

  def judge_now
    # runs the Judge, records the verdict
  end
end

class Submission::JudgeJob < ApplicationJob
  def perform(submission)
    submission.judge_now
  end
end
```

Solid Queue is the backend. Recurring tasks go in `config/recurring.yml`.

## Current

`Current` carries the request context (`session`, `user`, request metadata). Setting
`session` derives `user` from it, the same way Fizzy derives `identity`/`user`.
Models may read `Current` for **defaults** (`default: -> { Current.user }`), never for
control flow buried deep in domain logic — pass explicit arguments there.

`Current.user` **is** the competing team when `staff` is false — there is no `Team`
model and no `Current.team` (ADR-0011).

## Scale guardrail

~15 teams, one machine, three hours. Reject any abstraction justified by scale
(caching layers, sharding, API versioning, feature flags). The failure mode that
matters is "breaks on the night", not "won't scale" — prefer boring code that is easy
to verify over clever code that is easy to extend.
