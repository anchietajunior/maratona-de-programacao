# Controller & routing rules

Source: Basecamp's Fizzy. Controllers are HTTP adapters — a few lines that call one
expressive model method. If a controller action has logic worth testing on its own,
the logic is in the wrong place (see `docs/rules/architecture.md`).

## REST only — new resource over custom action

Every endpoint is one of the seven CRUD actions on a resource. When an operation
doesn't map to a CRUD verb, **introduce a resource that names the state change**,
never a custom action:

```ruby
# Bad
resources :submissions do
  post :rejudge
end

# Good — rejudging is creating a Judgement
resources :submissions do
  resource :judgement, only: :create
end
```

Fizzy's catalog of this pattern: `resource :closure` (close/reopen a card),
`resource :goldness`, `resources :not_nows`. Ours will look like
`resource :answer` (answer a clarification), `resource :delivery` (deliver a balloon),
`resource :publication` (publish standings).

Sub-resource controllers are namespaced by parent: `Submissions::JudgementsController`
in `app/controllers/submissions/judgements_controller.rb`.

## Controller shape

```ruby
class SubmissionsController < ApplicationController
  before_action :set_problem, only: %i[ create ]

  def create
    @submission = @problem.submissions.create! submission_params.merge(team: Current.team)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @problem }
    end
  end

  private
    def set_problem
      @problem = Contest.current.problems.find params[:problem_id]
    end

    def submission_params
      params.expect(submission: [ :code ])
    end
  end
```

- `before_action` setters are private, named `set_<resource>`, and **scope through
  the authority** (`Current.team.submissions.find ...`), never `Model.find(params[:id])`.
  Scoping *is* the authorization for ownership; there is no policy layer.
- Strong params use `params.expect`.
- Explicit permission checks are `ensure_*` before_actions that `head :forbidden`.
- Use `create!`/`update!` — invalid input from our own forms is a bug, and it should
  be loud.

## Shared behavior → controller concerns

Cross-controller behavior lives in `app/controllers/concerns/` and reads like a
capability: `Authentication`, `StaffScoped`, `SubmissionScoped`. A concern that only
sets an ivar from params is fine — that's Fizzy's `CardScoped`.

`ApplicationController` stays a short stack of `include` lines.

## Two audiences, two surfaces

Team screens and staff screens never share controllers. Staff controllers are
namespaced (`Staff::SubmissionsController`, routes under a `staff` scope) with the
access check in one base controller. What is secret is the *ranking*, not the
verdict (Art. 34) — a team controller must never be able to render another team's
data, by construction (scoping through `Current.team`).
