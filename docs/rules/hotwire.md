# Hotwire rules (reactivity)

Source: Basecamp's Fizzy. This file decides **how a screen gets reactive**. The
default answer is "it doesn't need to be" — climb this ladder and stop at the first
rung that covers the requirement. Every rung you skip is JavaScript you don't debug
at 21:30 on the night of the event.

## The ladder

**1. Turbo Drive (default).** A form posts, the controller redirects, the page
re-renders. No code. Most staff CRUD (registering problems, test cases, teams) stays
here — a screen only the actor is looking at needs no broadcasting.

**2. Morphing page refresh — the default for real reactivity.** When *other* people
must see a change, broadcast a refresh and let morphing update the page in place:

```ruby
# app/models/submission/broadcastable.rb
module Submission::Broadcastable
  extend ActiveSupport::Concern

  included do
    broadcasts_refreshes_to ->(submission) { submission.team }
    broadcasts_refreshes_to ->(submission) { :staff_submissions }
  end
end
```

```erb
<%# the team's scoreboard page %>
<%= turbo_stream_from Current.team %>
```

The layout sets morphing globally, once (Fizzy does exactly this):

```erb
<% turbo_refreshes_with method: :morph, scroll: :preserve %>
```

The page re-renders server-side and morphs — scroll, focus and open elements
survive. This is one `broadcasts_refreshes_to` line per audience; there is no
per-element bookkeeping to get wrong. **Prefer this over hand-written streams.**

**3. Turbo Frames** for interaction scoped to one region: in-place editing
(`turbo_frame_tag comment, :container`), and lazy-loading an expensive region
(`turbo_frame_tag card, :columns, src: ...`). Frames are navigation scoping, not
broadcasting — don't use them to push data.

**4. Hand-written `*.turbo_stream.erb`** only when a single action must update
several distinct regions *for the actor* and a redirect would lose state. Use
`method: :morph` on replaces. If the template updates more than ~3 targets, go back
to rung 2 — you are re-implementing a page refresh by hand.

**5. Stimulus** for state that lives only in the browser: the contest countdown
(rendered from server time, ticked client-side), auto-submit, clipboard. A Stimulus
controller never fetches data the server could have pushed.

## Never

- **No polling.** No `setInterval` + fetch, no meta-refresh. Rung 2 exists.
- **No custom Action Cable channels.** `turbo_stream_from` + broadcasts cover every
  need here; Solid Cable is the backend (database-backed, offline-safe).
- **No JSON endpoints consumed by hand-rolled JS.** HTML over the wire.

## Broadcasting mechanics

- Broadcasts live in a per-model `Broadcastable` concern, nothing else in it
  (Fizzy's `Card::Broadcastable`).
- Model-triggered broadcasts already run after commit and enqueue jobs — don't wrap
  them in `_later` plumbing of your own.
- Debounce comes free: `broadcasts_refreshes` coalesces bursts; don't build throttling.

## Where reactivity is required in this app

| What happens | Who must see it, live | Mechanism |
|---|---|---|
| Verdict lands on a submission | The owning team (scoreboard), staff monitor | Rung 2: refresh to `team` and `:staff_submissions` |
| Clarification asked | Staff queue | Rung 2 |
| Clarification answered to all | Every team's screen | Rung 2: refresh to a shared `:announcements` stream |
| Balloon earned | Balloon/staff screen | Rung 2 |
| Contest clock | Everyone | Rung 5: Stimulus countdown from server-rendered start time |
| Standings during contest | **Nobody** (Art. 34) | Nothing — staff loads it on demand |

## The secrecy guardrail (Art. 34)

A team's page subscribes only to streams derived from `Current.team` and to shared
all-teams streams (`:announcements`) that never carry ranking data. Never broadcast
standings, another team's verdicts, or aggregate counts onto any stream a team page
subscribes to — the leak happens at broadcast time, not render time.
`turbo_stream_from` signs stream names; keep team streams keyed by the team record
so one team cannot subscribe to another's.
