# Honesty

bOS documents what is enforced by code, what is best-effort prompting, and what does not exist. Every claim below is verifiable from disk:

```bash
bash scripts/bos-roster.sh   # counts skills/agents/hooks, exit 1 on drift
bash tests/run.sh            # guard payloads, bus schema, clean-clone check
```

## The table

| REAL (enforced by code) | BEST-EFFORT (prompting) | Does not exist |
|-------------------------|-------------------------|----------------|
| User state is untracked: `state/*.md` is gitignored, blank templates ship in `templates/state/`, session-start materializes them | Ambient capture (energy/expense mentioned → logged) | Background daemon or 24/7 automation |
| 6 hooks wired in `.claude/settings.json` | Crisis-data ephemerality and send/spend consent on non-Claude hosts (prompt contract) | Automatic cloud backup of your data |
| 24 skills, `tier: core` (16) or `optional` (8), each SKILL.md ≤ 8 KB | Personas of @boss (ceo, coo, cfo, …) — roles, never separate processes | Cloud service, hosted sync, SQLite backend |
| 10 agent files | Routing accuracy ~60-80%, not 100% | Unprompted morning check-ins or weekly nags |
| Message bus: single writer script with schema validation | Grok integration (see per-CLI matrix below) | Mid-generation message injection |
| Clickable questions via AskUserQuestion (Claude) | | `git push` inside `/ship` (always a separate, explicit ask) |

## What "enforced" honestly means

The `protect-state` guard blocks the model's own predictable mistakes before they happen: hand-edits of the message bus, writes into `state/archive/` and `state/.backup/`, in-session edits of `settings.json` — including the obvious Bash routes (`rm`, `find -delete`, `truncate`, redirects, `sed -i`, interpreter one-liners). The test suite feeds it hostile payloads on every CI run.

It is a **speed bump against accidents, not a security boundary**. A guard built on command inspection cannot enumerate every interpreter trick, and we will not pretend otherwise. If your threat model includes a malicious actor driving the session, no hook in this repo stops them — your OS permissions and judgment do.

Two more things worth knowing:

- **Hooks run outside the CLI permission model.** The deny-list in `settings.json` (no `curl`, no `git push`, no `rm` from chat) governs what the model may run in conversation. Hook scripts are not subject to it — e.g. the optional evening push in `session-end.sh` uses `curl` to ntfy, and only if you created `.secrets/ntfy.env` yourself.
- **The jsonl bus has no file locking.** Entries are capped at 2000 chars, which keeps a line under PIPE_BUF, so concurrent appends stay atomic on macOS/Linux. Deliberate simplicity, documented rather than hidden.

## Per-CLI reality

| CLI | What actually runs |
|-----|--------------------|
| **Claude Code** | Full enforcement: all 6 hooks fire (state injection, guard, logging, digests), AskUserQuestion works. This is the reference host. |
| **Codex** | Context injection: `.codex/hooks.json` wires session-start and time-aware. No PreToolUse guard, no session-end. If your build doesn't inject hook stdout, Read `AGENTS.md` manually. |
| **Grok** | Prompt-only: hook stdout is ignored entirely. The contract asks the model to Read `AGENTS.md`, `state/handoff.md`, and `state/ping.md` every turn. It works when the model complies — that is best-effort by definition. |

`/ship` stages files by explicit name only (`git add .` is forbidden in the skill) and checks the staged diff for `state/`, `profile.md`, `.secrets/` before committing.

`/home` is a snapshot built from your state files, not a dashboard product. `/morning` and `/evening` run **only when you ask** — a greeting never triggers a ritual. Live skill list: [config/roster.md](config/roster.md) (generated; do not hand-edit).
