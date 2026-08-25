---
name: check
description: "Read-only health check of profile, state, hooks, and roster. Use when the user says /check, health check, or czy działa."
user_invocable: true
command: /check
tier: core
---

# /check — report only

**Read `references/diagnostics.md` only if you need schema detail.** Core path:

Do not auto-repair, install MCP, or "fix all".

1. `bash scripts/bos-roster.sh` when Bash is allowed. Show its table (skills, **tier**, 8KB, hooks). Missing `tier: core|optional` = drift.
2. `profile.md`: Name, packs, primary goal filled? Else say run `/setup`.
3. Files exist: `AGENTS.md`, `state/tasks.md`, `state/daily-log.md`, `state/finances.md`, `scripts/context-bus-append.sh`. Bus live file = `state/context-bus.jsonl` (missing/empty is valid). Stub `state/context-bus.md` is not the bus.
4. Ten agent files in `.claude/agents/`.
5. `.claude/hooks/` = 6 wired + `ping-inject.sh`. ntfy is examples only.
6. Secrets: `.secrets/` edited locally; no `/vault`.

Overall: OK or list issues. Next step = one fix the user can choose, not a silent write.
