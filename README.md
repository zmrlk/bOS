# bOS — a folder OS

**A personal operating system for brains that sprint and crash.** Built ADHD-first: max 3 visible tasks, streaks that decay instead of resetting, energy over time, crisis data never persisted — and the guardrails are enforced by hooks, not promises.

It is just a folder: markdown files, skills, and hooks. Open it in **Claude Code** (full enforcement; Codex and Grok work with reduced wiring — see [HONESTY.md](HONESTY.md)). Your tasks, finances, habits, and goals live in plain-text files on your machine. No server, no database, no daemon.

> **v0.13.0** — `git clone https://github.com/zmrlk/bOS.git`

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
- **Code (permissions, Claude Code):** `git push`, `rm`, `sudo`, `curl` are deny-listed in chat; destructive actions require a separate, explicit yes.
- **Contract (prompt, all hosts):** crisis conversations are never persisted — no notes, no logs, external hotlines instead (Rule 12). Send/spend consent on non-Claude hosts is also contract, not hook.
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

## Optional extras

Everything under `examples/` is a sample, not a dependency: ntfy push notifications for macOS, a Supabase mirror schema, n8n workflow templates, and two skills (`vault`, `schedule`) that need extra setup before they are safe to enable. A fresh clone works without any of it.

Secrets live in a local `.secrets/` directory you create yourself (`chmod 700`, files `600`) — never paste keys into chat.

## Limits

One model wearing roles routes correctly ~60-80% of the time, not 100%. Data quality equals what you tell it. Privacy model: [PRIVACY.md](PRIVACY.md). What's real vs. aspirational: [HONESTY.md](HONESTY.md). Cross-CLI contract: [AGENTS.md](AGENTS.md).

License: [MIT](LICENSE).
