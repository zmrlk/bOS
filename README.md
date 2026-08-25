# bOS — a folder OS

A folder of markdown, skills, and hooks. Open it in **Claude Code**, **Codex**, or **Grok**. Same files on all three.

> **v0.12.1** — honesty freeze from 0.12, plus jsonl bus + one helper, and roster `tier: core|optional`.
>
> Clone: `git clone https://github.com/zmrlk/bOS.git`

This is **not** a 24/7 daemon, not a kernel, not Karol's private ICC fleet, and not VARD.

## Honest picture (count from disk)

Verify anytime:

```bash
bash scripts/bos-roster.sh
```

| REAL (code) | BEST-EFFORT (prompt) | Does not exist |
|-------------|----------------------|----------------|
| 6 hooks wired in `.claude/settings.json` | Ambient capture (energy/expense mentioned → log) | 24/7 daemon, Pulse, Broker, SQLite kernel |
| 24 Lite skills, `tier: core` (17) or `optional` (7), SKILL.md ≤ 8 KB | Personas of @boss (ceo, coo, cfo, …) — never spawned | `/vault` in chat, `/schedule` in Lite |
| 10 agent files | Grok ping: you must **Read** `state/ping.md` (hook stdout is ignored) | Auto morning interrogation, weekly nag |
| Bus: `bash scripts/context-bus-append.sh` → `state/context-bus.jsonl` | | Mid-generation inject |
| AskUserQuestion (Claude) | | `git push` inside `/ship` (denied; ask separately) |

Live skill list: [config/roster.md](config/roster.md) (generated; do not hand-edit). Missing `tier:` = drift.

`/home` is a **Summary snapshot** from files, not a product dashboard. `/morning` and `/evening` run **only if you ask**. Greetings are not energy and do not start `/morning`.

## Quick start

1. Install [Claude Code](https://claude.ai/code), or Codex CLI, or Grok.
2. `git clone https://github.com/zmrlk/bOS.git` and open that folder.
3. Say "hi". If `profile.md` is empty → `/setup`.

**Claude:** SessionStart is REAL. **Codex:** `.codex/hooks.json` points at the same scripts — if your Codex build does not inject hook stdout, Read `AGENTS.md` (BEST-EFFORT). **Grok:** hook stdout is ignored — Read `AGENTS.md`, `state/handoff.md`, and `state/ping.md` every turn.

Write to a running session: one message in `state/ping.md`. Consumed on the **next turn**, not mid-generation.

## Team

Ten files. Conversational titles (ceo, coo, sales, …) are **personas of @boss**, never spawned.

| Area | Files |
|------|--------|
| Core | @boss |
| Business | @cto @cmo @advocate |
| Design | @design |
| Life | @coach @finance |
| Health | @trainer @diet |
| Learning | @reader |

## Bus

The only writer:

```bash
bash scripts/context-bus-append.sh <from> <to> <type> <priority> "<content>" [ttl_days]
```

Never `echo >>` jsonl. `protect-state` blocks hand-edit. TTL is a **read filter** in SessionStart, not a rewrite kernel. `state/context-bus.md` is a stub. The live jsonl is gitignored (your signals do not ship).

## Optional (not Lite)

Calendar/email via `/connect`. macOS ntfy: `examples/hooks/ntfy/` (`install-layer3.sh` hard-fails without a topic). `examples/supabase`, `examples/templates/n8n`, `examples/skills/vault`, `examples/skills/schedule` are samples. Clone works without them.

Secrets: create `.secrets/` yourself (`chmod 700`, files `600`). Never paste keys into chat.

## Limits

One model wearing roles (~60–80% routing). Data quality = what you say. See [PRIVACY.md](PRIVACY.md). Contract: [AGENTS.md](AGENTS.md). Claude overlay: [CLAUDE.md](CLAUDE.md).

License: [MIT](LICENSE).
