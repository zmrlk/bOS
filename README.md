# bOS — a folder OS

A personal operating system that is just a folder: markdown files, skills, and hooks. Open it in **Claude Code**, **Codex**, or **Grok** — same files, same behavior on all three.

Your tasks, finances, habits, goals, and decisions live in plain-text state files. The model reads them, updates them, and talks to you like an operator — no server, no database, no daemon.

> **v0.12.1** — `git clone https://github.com/zmrlk/bOS.git`

## What it is (and what it is not)

bOS is deliberately honest about which parts are enforced by code and which are best-effort prompting. Verify anytime against the disk:

```bash
bash scripts/bos-roster.sh
```

| REAL (enforced by code) | BEST-EFFORT (prompting) | Not included |
|-------------------------|-------------------------|--------------|
| 6 hooks wired in `.claude/settings.json` | Ambient capture (energy/expense mentioned → logged) | Background daemon or 24/7 automation |
| 24 skills, `tier: core` (17) or `optional` (7), each SKILL.md ≤ 8 KB | Personas of @boss (ceo, coo, cfo, …) — roles, never separate processes | Cloud service, hosted sync, SQLite backend |
| 10 agent files | Grok ping: you must **Read** `state/ping.md` (hook stdout is ignored) | Unprompted morning check-ins or weekly nags |
| Message bus: `bash scripts/context-bus-append.sh` → `state/context-bus.jsonl` | | Mid-generation message injection |
| Clickable questions via AskUserQuestion (Claude) | | `git push` inside `/ship` (always a separate, explicit ask) |

Live skill list: [config/roster.md](config/roster.md) (generated; do not hand-edit).

`/home` is a snapshot built from your state files, not a dashboard product. `/morning` and `/evening` run **only when you ask** — a greeting never triggers a ritual.

## Quick start

1. Install [Claude Code](https://claude.ai/code), Codex CLI, or Grok CLI.
2. `git clone https://github.com/zmrlk/bOS.git` and open the folder in your CLI.
3. Say "hi". If `profile.md` is empty, the system runs `/setup` — a 3-minute onboarding.

Windows note: `.agents/skills/` uses git symlinks. Clone with `git clone -c core.symlinks=true …` (requires Developer Mode or admin) — otherwise Codex-style agents see plain text files instead of the skills.

Per-CLI notes:

- **Claude Code:** hooks are fully wired — SessionStart injects your state summary automatically.
- **Codex:** `.codex/hooks.json` points at the same scripts. If your build does not inject hook stdout, Read `AGENTS.md` at session start.
- **Grok:** hook stdout is ignored — Read `AGENTS.md`, `state/handoff.md`, and `state/ping.md` every turn.

To message a running session from outside: write one line into `state/ping.md`. It is consumed on the next turn (never mid-generation).

## Team

Ten agent files, one orchestrator. Conversational titles (ceo, coo, sales, …) are **personas of @boss**, not separate agents.

| Area | Agents |
|------|--------|
| Core | @boss |
| Business | @cto @cmo @advocate |
| Design | @design |
| Life | @coach @finance |
| Health | @trainer @diet |
| Learning | @reader |

## Message bus

Cross-session signals go through one helper (the only writer):

```bash
bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]
```

Never append to the jsonl by hand — the `protect-state` hook blocks it. TTL is a read filter applied at session start, not a background process. The live `state/context-bus.jsonl` is gitignored: your signals never ship with the repo.

## Optional extras

Everything under `examples/` is a sample, not a dependency — a fresh clone works without any of it:

- `examples/hooks/ntfy/` — push notifications on macOS (`install-layer3.sh` refuses to run without your own topic)
- `examples/supabase/` — schema for an optional cloud mirror
- `examples/templates/n8n/` — inbox/cron workflow templates
- `examples/skills/vault`, `examples/skills/schedule` — skills that need extra setup before they are safe to enable

Calendar/email integrations connect via `/connect` (MCP). Secrets live in a local `.secrets/` directory you create yourself (`chmod 700`, files `600`) — never paste keys into chat.

## Limits

One model wearing roles routes correctly ~60–80% of the time, not 100%. Data quality equals what you tell it. Privacy model: [PRIVACY.md](PRIVACY.md). Shared cross-CLI contract: [AGENTS.md](AGENTS.md). Claude-specific overlay: [CLAUDE.md](CLAUDE.md).

License: [MIT](LICENSE).
