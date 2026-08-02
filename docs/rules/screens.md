# Screen rules (views, Turbo, Stimulus, Tailwind)

Source: Basecamp's Fizzy for structure and Hotwire usage.
**`docs/design.md` is the design authority** for everything visual — typography,
colors, spacing, radii, components, breakpoints. Use its tokens; never invent a hex
value, a font size, or a shadow. It bans drop shadows (hairline-only depth), caps
display weight at 400, and reserves the primary color for the main CTA — respect that
even when a Tailwind default makes the alternative easier.

## Language

Everything the user sees is **Portuguese**, via `config/locales/pt-BR.yml` — never
hardcoded in views. Templates, partials, helpers, Stimulus code: English.

## View structure

- One folder per resource; partials named after the resource (`submissions/_submission.html.erb`)
  and rendered with explicit locals.
- A big screen decomposes into sub-partials in a subfolder, the way Fizzy splits
  `boards/show/` into `_column`, `_stream`, `_closed`.
- Page chrome via `content_for` (`:header`, `:head`); the layout stays generic.
- Complex tag building (a submission row's classes/data varying by verdict) goes in a
  **helper**, not inline ERB — see Fizzy's `card_article_tag` for the shape. Helpers
  build tags with `tag.*` / `class: [ ... ].compact`.

## Turbo — see `docs/rules/hotwire.md`

Anything involving reactivity — live updates, broadcasts, frames vs streams, what
must *not* be broadcast — is governed by `docs/rules/hotwire.md`. Follow its ladder;
don't decide the mechanism here.

## Stimulus

- Controllers are small, single-purpose, named after the behavior:
  `auto_submit_controller.js`, `countdown_controller.js`, `copy_to_clipboard_controller.js`.
- Use the declarative APIs — `static values`, `static targets`, `static classes` —
  and `#private` methods for internals. No querySelector soup, no state outside the
  DOM/values.
- New JS dependencies via `bin/importmap pin` only (and remember ADR-0005: the lab is
  offline — vendored, never CDN).

## Tailwind

- Utilities in the markup are fine (that's the tool), but the *values* must resolve
  to `docs/design.md` tokens — extend the Tailwind theme with the design tokens
  (colors, fonts, radii, spacing) once, then use only those names.
- Repeated component markup (buttons, cards, pills) becomes a partial or helper, not
  a copied utility string.

## The two audiences (from CLAUDE.md)

Teams are undergraduates under time pressure on one shared machine: screens must be
obvious without training — one primary action per screen, verdicts in plain language,
no hover-only affordances. Staff screens can be denser. A team screen renders that
team's data only; nothing on it may leak ranking (Art. 34).
