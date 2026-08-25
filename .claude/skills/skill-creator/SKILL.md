---
name: skill-creator
description: "Create or improve a skill. Use when the user wants a new skill, to update a skill, or to run skill evals."
tier: core
---

# Skill creator

**Read `references/workflow.md` before writing files.** Capture intent from this chat first.

Loop: intent → draft SKILL.md (framework) → user confirms → iterate.

Must:
- Frontmatter `name` + description that states **when to trigger** + `tier: core` or `tier: optional` (roster drifts without it)
- SKILL.md ≤ 8 KB; long protocol in `references/`
- Hard rules stay in SKILL.md so a lazy load still behaves
- First lines of SKILL.md: "Before answering, Read `references/…`"
- Do not duplicate AGENTS.md
- Do not add to Lite until the user asked and `bash scripts/bos-roster.sh` stays green

Evals/viewer/optimizer: `references/workflow.md`, `references/schemas.md`. Skip eval theater if the user said "just write it".
