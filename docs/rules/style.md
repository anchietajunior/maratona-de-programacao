# Ruby style rules

Source: Basecamp's Fizzy `STYLE.md`, verbatim in spirit. RuboCop
(rubocop-rails-omakase) enforces layout; these are the judgment calls it can't.
Language, comment, and RBS rules are in `CLAUDE.md` → Conventions — they apply on
top of everything here.

## Expanded conditionals over guard clauses

Default to the expanded form:

```ruby
# Bad
def testcases_for(problem)
  return [] unless problem.published?
  problem.testcases.ordered
end

# Good
def testcases_for(problem)
  if problem.published?
    problem.testcases.ordered
  else
    []
  end
end
```

Guard clauses are acceptable only when the return sits at the very top of a method
whose body is several lines:

```ruby
def broadcast_verdict
  return if drafted?

  # ...several lines...
end
```

## Method ordering

1. Class methods.
2. Public methods, `initialize` first.
3. Private methods — ordered by **invocation order**: a private method appears right
   after the flow that calls it, so the file reads top-down like the execution.

## Visibility modifiers

No blank line under `private`; indent the methods beneath it:

```ruby
class Judge
  def judge(code, cases)
    # ...
  end

  private
    def run_container(code, input)
      # ...
    end
end
```

In a module that is entirely private, put `private` at the top, one blank line after,
no extra indent.

## Bang methods

`!` only when a non-bang counterpart exists (`create`/`create!`). Never use `!` to
signal "dangerous" — plenty of destructive Rails methods have no bang.

## When unsure

Find similar code in this repo (or in Fizzy) and match it. Consistency with the
codebase beats personal preference — the goal is code that reads like one person
wrote it.
