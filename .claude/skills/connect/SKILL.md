---
name: connect
description: "Manage MCP connections — list, add, test, remove. Use when the user wants to connect a tool or says /connect."
user_invocable: true
command: /connect
tier: optional
---

# /connect

**Read `mcp-catalog.md` first, then `references/modes.md` for the mode you are in.**

Never install without confirmation. Never enable all MCP servers. After a real test call succeeds, update `profile.md → Connected MCPs`. Score <8 → do not install. Paid service → show price first.

| Command | Do |
|---------|-----|
| `/connect` | Status from profile + a test if already listed |
| `/connect [service]` | Match catalog → show benefit/command → ask → install → test |
| `/connect list` | Catalog, highlight by packs |
| `/connect test` | Probe each connected server; report OK/fail |
| `/connect remove [name]` | Confirm, then remove, then profile |

If ToolSearch finds nothing, omit that connector. No "MCP unavailable" theater.
