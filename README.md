# bOS — a folder OS

**A personal operating system for brains that sprint and crash.** Built ADHD-first: max 3 visible tasks, streaks that decay instead of resetting, energy over time. Where a guardrail can be enforced by code it is a hook, not a promise — and [HONESTY.md](HONESTY.md) says exactly which is which.

It is just a folder: markdown files, skills, and hooks. Open it in **Claude Code** (full enforcement; Codex and Grok work with reduced wiring — see [HONESTY.md](HONESTY.md)). Your tasks, finances, habits, goals, and confirmed cross-session memory live in plain-text files on your machine. No server, no database, no daemon.

> **v0.14.0** — `git clone https://github.com/zmrlk/bOS.git`

## What a session looks like

*(example session — Alex is the fixture persona from `/setup`)*

```
> morning
☀️ Morning, Alex. Yesterday's evening energy: 5/10 — lighter plan today.
🗓️ TODAY: 10:00 dentist · 14:00 call with Sam
✅ PLAN (max 3 — that's the rule, not a suggestion)
   1. Send Sam the invoice draft (~45 min)
   2. Book the car service (5 min — quick win, do it first)
   3. Read ch. 4 (only if energy holds)

> btw spent 40 on lunch
⏳ Logged: 40 (Food) → state/finances.md.

> remember that I want the answer first, then evidence
💾 Saved → memory/current/user--answer-style.md

> /habit
🚭 Day 47 smoke-free — about 470 saved.
   Tuesday's slip? The streak decays, it doesn't reset to zero.
   You don't lose 46 days of progress to one evening.

⏭️ Next step: the invoice draft. One thing. Just one.
```

Everything above is a file you can open: the plan reads `state/tasks.md`, the expense lands in `state/finances.md`, the quit-tracker lives in `state/habits.md`.

## Guardrails — what is code, what is contract

- **Code (hook):** a PreToolUse guard blocks hand-edits of the message bus, destructive ops on archives, and in-session `settings.json` edits — fed hostile payloads in CI on every push. It's a speed bump against the model's mistakes, not a security boundary ([HONESTY.md](HONESTY.md) says exactly where the line is).
- **Code (boundary):** your data lives in untracked `state/` files — git never sees them, so a commit or push cannot ship them.
- **Code (memory):** one local store works across Claude/Codex/Grok; conflicts quarantine instead of overwriting, stale records leave the startup cache, and known secret/crisis/injection patterns are rejected. Provenance is auditable, not cryptographically proven. See [docs/MEMORY.md](docs/MEMORY.md).
- **Code (permissions, Claude Code):** `git push`, `rm`, `sudo`, `curl` are deny-listed in chat; destructive actions require a separate, explicit yes.
- **Contract (prompt, all hosts):** crisis conversations are never persisted — no notes, no logs, external hotlines instead (the crisis rule — AGENTS.md rule 9). Send/spend consent on non-Claude hosts is also contract, not hook.
- Every claim is auditable from disk: `bash scripts/bos-roster.sh` + `bash tests/run.sh`. Full breakdown: [HONESTY.md](HONESTY.md).

## Quick start

1. Install [Claude Code](https://claude.ai/code) (or Codex CLI / Grok CLI — reduced wiring, see [HONESTY.md](HONESTY.md)).
2. `git clone https://github.com/zmrlk/bOS.git` and open the folder in your CLI.
3. Say "hi". If `profile.md` is empty, `/setup` runs — detection-first, max 5 questions, under 3 minutes.

Windows note: `.agents/skills/` uses git symlinks — clone with `git clone -c core.symlinks=true …` (needs Developer Mode or admin).

To message a running session from outside: write one line into `state/ping.md`. It is consumed on the next turn.

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

Cross-session signals go through one schema-validating writer:

```bash
bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]
```

Hand-appending the jsonl is blocked by the guard hook. The live bus file is gitignored — your signals never ship with the repo.

## Durable memory

`/remember` saves only explicitly confirmed facts. `memory/current/` holds the
current value, incompatible proposals go to `memory/conflicts/`, superseded
versions go to `memory/archive/`, and a small `memory/HOT.md` is loaded at
session start. `/recall` reports file/source locators and falls back to session
history. The store is local, gitignored, and shared by all three CLIs.

It is deliberately lexical and inspectable — no vector database and no claim
that a model-generated session summary is automatically true. Full design:
[docs/MEMORY.md](docs/MEMORY.md).

## Optional extras

Everything under `examples/` is a sample, not a dependency: ntfy push notifications for macOS, a Supabase mirror schema, n8n workflow templates, and two skills (`vault`, `schedule`) that need extra setup before they are safe to enable. A fresh clone works without any of it.

Secrets live in a local `.secrets/` directory you create yourself (`chmod 700`, files `600`) — never paste keys into chat.

## Limits

One model wearing roles routes correctly ~60-80% of the time, not 100%. Data quality equals what you tell it. Privacy model: [PRIVACY.md](PRIVACY.md). What's real vs. aspirational: [HONESTY.md](HONESTY.md). Cross-CLI contract: [AGENTS.md](AGENTS.md).

License: [MIT](LICENSE).
