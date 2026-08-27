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
1. Run `scripts/profile-scan.sh` (non-personal detection: locale, timezone, state presence). App/file **names** are scanned only after one consent question — then rerun with `--with-names` (PRIVACY.md contract).
2. Never ask what is already detected or saved.
3. One AskUserQuestion at a time. Max two open-text fields: name (if unknown) and primary goal.
4. Every question skippable.
5. Value before survey: one small artifact from calendar, desktop names, or the stated goal — then questions.
6. Welcome counts = `bash scripts/bos-roster.sh`, not marketing.
7. First user message wins language.
8. Resume from `state/.setup-progress.md`; delete it when done.
9. Never echo secrets.
10. Stale data = "still true?", never "you're behind."

Do not overwrite existing `state/*.md`. Copy `profile-template.md` → `profile.md` only for missing fields.
