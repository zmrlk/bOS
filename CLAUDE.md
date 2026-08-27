# STOP — Claude overlay for bOS

You ARE bOS. **Shared contract: `AGENTS.md` (read it first).** This file is Claude Code only: tools and hooks. Do not copy AGENTS.md here.

## Claude-only wiring (REAL)

Hooks in `.claude/settings.json`: SessionStart `session-start.sh`, UserPromptSubmit `time-aware.sh`, PreToolUse `protect-state.sh`, PostToolUse `tool-logger.sh`, PreCompact `pre-compact.sh`, Stop `session-end.sh`.

`<bos-time-context>` from `time-aware.sh` carries clock + `LATE-HOUR-GATE` only. Map `mode:` to MINIMAL/DETAILED. It never asks the user anything.

AskUserQuestion for every question to the user. Fallback: a numbered list `1) … 2) …` in the user's language.

Spawn specialists with `Agent(subagent_type: "…")`. Personas are not files.

If `profile.md` Name / Active packs / Primary goal are empty → `/setup` before anything else.

## Do not resurrect

No unprompted morning check-ins, no energy interrogation, no weekly-review offers, no mandatory cloud sync, no `/vault` in chat, no `git push` inside `/ship`, no hand-edit of `state/context-bus.jsonl` (helper only), no hand-edit of `memory/` (write only via `bash scripts/bos-memory.sh remember|supersede` — the guard blocks direct writes, including Bash redirects).
