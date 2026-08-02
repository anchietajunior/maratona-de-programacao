# Testing rules

Source: Basecamp's Fizzy. Minitest + fixtures, nothing else — no RSpec, no
factories, no mocking library until a test genuinely cannot be written without one.

## Fixtures are the shared universe

- `test/fixtures/` holds one small, coherent world: a contest, a few teams, problems
  at each difficulty, submissions covering the interesting verdicts. Every test runs
  against it.
- Fixtures have story names (`users(:turing)`, `problems(:easy_sum)`,
  `submissions(:turing_accepted)`) — never `team1`, `record_a`.
- When a test needs a state the fixtures don't have, **mutate a fixture in the test**
  (`submissions(:turing_wrong).accept!`) rather than growing the fixture set for one
  case. Add a fixture only when several tests need the same starting state.

## Test placement mirrors code placement

- One test file per concern, in a folder per model — Fizzy tests `Card::Closeable`
  in `test/models/card/closeable_test.rb`. Do the same:
  `test/models/submission/scoreable_test.rb`.
- Controllers get integration tests (`test/integration/` or controller tests) that
  hit routes and assert responses/redirects — they test the HTTP surface, not domain
  logic (which the model tests already cover).
- There are **no system tests** — Capybara/Selenium were removed (see CLAUDE.md).

## Test shape

```ruby
class Submission::ScoreableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:turing)
  end

  test "penalty only counts for problems later solved" do
    assert_difference -> { users(:turing).total_time }, +10 do
      # ...
    end
  end
end
```

- Set `Current.session` in `setup` when the code under test reads context — mirror
  production, don't stub around it.
- Test names are sentences describing behavior, in English.
- Prefer `assert_difference` / `assert_no_difference` with lambdas for side effects.
- Assert the domain outcome (verdict recorded, event created), not implementation
  details (which methods were called).

## What must always have tests

The scoring rules are the product: all-or-nothing scoring, retroactive penalty,
derived `total_time`, verdict precedence. A change touching
`Submission`/`Scoreable`/`Judge` without covering its edge case is incomplete —
these are the rules "easy to get wrong" listed in CLAUDE.md, and the award ceremony
depends on them.

`test/judge_test.rb` needs Docker running and `python:3.12-slim` pulled; it starts
real containers (~5s). Keep it that way — a mocked judge test proves nothing about
the night of the event.
