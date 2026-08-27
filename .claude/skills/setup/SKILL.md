---
name: setup
description: "Detection-first onboarding. Use when profile.md is missing or empty, or the user says /setup."
user_invocable: true
command: /setup
tier: core
---

# /setup

**Read `references/flow.md` before the first user-facing question.** Without it you will interrogate — that is the failure mode.

Hard rules (also in flow.md):
0. Run `bash scripts/bos-memory.sh init`. It creates an empty local store and
   never copies profile, git identity, Claude memory, or scan results into it.
1. Run `bash .claude/skills/setup/scripts/profile-scan.sh --stamp` (non-personal detection: locale, timezone, state presence; `--stamp` records the start time ONCE, on this first invocation only — every later rerun goes without it). App/file **names** are scanned only after one consent question — then rerun with `--with-names` (PRIVACY.md contract; flags are valid in any argument position).
2. Never ask what is already detected or saved.
3. One AskUserQuestion at a time. Max two open-text fields: name (if unknown) and primary goal.
4. Every question skippable.
5. Value before survey: one small artifact from calendar, desktop names, or the stated goal — then questions.
6. Welcome counts = `bash scripts/bos-roster.sh`, not marketing.
7. First user message wins language.
8. Resume from `state/.setup-progress.md`; delete it when done.
9. Never echo secrets.
10. Stale data = "still true?", never "you're behind."
11. On Codex/Grok there is no AskUserQuestion — numbered lists replace clickable cards. The question cap matters MORE there, not less; the 3-minute goal is measured on Claude Code.
12. Close by saying Core is complete and the rest of `profile.md` fills itself with usage (progressive profiling). Never present empty non-Core sections as unfinished work.
13. FRESH_INSTALL → offer the 30-second demo first (`bash .claude/skills/setup/scripts/demo.sh start|end` — Alex fixture, never touches profile.md, refuses over real state).
14. Show progress on every question ("2/5"). Done = the rescan says so (`core_filled` + `mode`) and the measured duration is quoted — not a feeling.

Do not overwrite existing `state/*.md`. Copy `profile-template.md` → `profile.md` only for missing fields.
