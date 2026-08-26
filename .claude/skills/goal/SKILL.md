---
name: goal
description: "Set, update, review, or complete goals. Works with @coach (life goals) and @boss (business goals)."
user_invocable: true
command: /goal
tier: core
---

# /goal

**Read `references/flows.md` before the first user-facing reply.** Subcommand steps, display layouts, and bus signals live there.

Subcommands: `/goal` (show, default) · `set [description]` · `update [#] [note]` · `done [#]` · `review`. A bare goal description with no subcommand = `set`.

## Do this

1. Parallel Read, one turn: `state/goals.md`, `profile.md` (primary_goal, adhd_indicators).
2. Category → owner, auto-detected from the goal text: business/work/revenue/clients → @boss · health/fitness/weight/exercise → @coach · learning/skill/language/reading → @reader · life/habit/routine/relationship → @coach.
3. Every choice is an AskUserQuestion (deadline options: 1 week / 1 month / 3 months / 6 months). Max one open-text question: the goal itself, and only if the user gave none.
4. Writes go to `state/goals.md` only (Active Goals, Milestones, Completed Goals). Bus writes only via `bash scripts/context-bus-append.sh` — exact signals in flows.md.
5. Review flags risk at >50% time elapsed with <25% progress, and ends with the one goal that deserves this week's focus.

## ADHD adaptation (core behavior, not garnish)

Check `profile.md → adhd_indicators` before every goal operation. If yes/suspected:

- Frame goals as challenges with countdowns, not obligations.
- Max 2 goals visible; if more exist, say these two matter most right now.
- Milestones short (1–2 weeks, never months) so the first win lands fast.
- Make progress visible on every update: progress bar, streak count, named milestones. Acknowledge completions concretely (what, how long) — genuine, never scripted hype.
- Review shows wins before risks.

Per-subcommand display variants are in `references/flows.md`.
