# /evolve audit rubric

Loaded by `evolve/SKILL.md`. On-demand only — never scheduled, never self-triggered.
Report findings; change nothing without the user approving one named proposal.

## Audit checklist

1. **Roster vs disk.** `bash scripts/bos-roster.sh` — skills count, `tier:` present on all, nothing over 8 KB, hooks wired = 6 + ping-inject helper. Any mismatch = drift; propose the fix, do not apply it.
2. **Profile completeness.** `profile.md` vs the template: Name, Active packs, Primary goal filled? Stale fields (>30 days on dynamic data) → flag with date.
3. **State hygiene.** Growing files (`daily-log.md`, `finances.md`) have a current Summary; small files parse; `state/context-bus.jsonl` is helper-written only. Empty or missing runtime files on a fresh install are normal — say so, do not "repair".
4. **Contradictions.** Skill descriptions vs actual behavior, AGENTS.md vs README, help text vs real commands. Every contradiction found is a proposal, not a silent edit.
5. **Usage patterns (only from data the user shows or files on disk).** Unused skills are a candidate for `tier: optional`, not deletion. Never fabricate usage stats.

## Proposals

At most 5. Each proposal states:
- **What** — one concrete change (file + edit).
- **Why** — the observation that motivates it.
- **Cost** — time/tokens/complexity added.
- **Kernel check** — purpose, budget, capacity, health, values, safety. Any gate failing → the proposal is dead.

Automatic NO for any proposal that adds: a daemon or scheduled run, a second bus or memory store, auto-patching of agent files or CLAUDE.md/AGENTS.md, auto-created skills, or anything the Honesty table lists as DOES NOT EXIST.

A class of proposal rejected twice by the user is retired — stop suggesting it.

## Output

Short report: roster table, issues found (grouped: drift / contradictions / hygiene), then the numbered proposals. End with one next step the user can pick.
