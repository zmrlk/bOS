---
name: evolve
description: "On-demand audit of bOS. Use when the user says /evolve, improve yourself, or audit the system. Never auto-run weekly or monthly."
user_invocable: true
command: /evolve
tier: core
---

# /evolve — manual only

**Read `references/protocol.md` for the audit rubric.** Then report. Do not install, patch agent files, or create skills unless the user approves one named proposal.

1. `bash scripts/bos-roster.sh` if Bash is allowed — paste the table.
2. Profile vs empty template.
3. State files exist. Do not auto-repair.
4. At most 5 proposals. Each: purpose, cost, and NO if it adds a daemon, second bus, or auto-cron.
5. Objective Kernel only as a checklist (purpose, budget, capacity, health, values, safety) — not a self-modifying loop.

Rejected twice → stop suggesting that class.
