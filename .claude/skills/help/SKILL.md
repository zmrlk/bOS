---
name: help
description: "Show all available commands, agents, and shortcuts. The go-to reference when users don't know what to do."
user_invocable: true
command: /help
tier: core
---

# /help — What can I do?

Show a clean, one-screen reference of everything available.

**Adapt to tech_comfort:** "not technical" → simple language, group by action ("Want to plan your day?"). "I use apps" → list commands with brief descriptions. "I code" → compact table with command names.

---

## Layout

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️  bOS — Help
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🤖  YOUR AGENTS
  [List only active agents from profile.md → active_agents]
  [emoji] @agent — tagline
  [emoji] @agent — tagline
  ...
  Type @agent to talk directly to them.

  ⌨️  DAILY RHYTHM (on demand — bOS never nags you into these)
  /morning          — start-of-day briefing
  /evening          — end-of-day log
  /home             — dashboard

  📋  WORK
  /task             — add, list, complete tasks
  /goal             — set and review goals
  /decide           — structured decision with a verdict
  /wrap-up          — close a session with a handoff note
  /follow-up        — follow-up script for a contact
  /ship             — review, commit (push is a separate ask)

  💰  TRACKING
  /expense          — log spending
  /habit            — streaks, habits, quit tracker
  /workout          — log exercise
  /reflect          — one-question micro-journal

  🔎  MEMORY & INBOX
  /remember         — save a confirmed fact to durable memory
  /recall           — search durable memory + session history
  /remind           — set a timed reminder
  /inbox            — email triage (Gmail + Outlook)
  /network          — contacts and follow-ups

  ⚙️  SYSTEM
  /setup            — onboarding / profile refresh
  /check            — system health check
  /evolve           — audit and improve bOS itself
  /connect          — manage MCP connections (optional)
  /build-agent      — create a custom agent (optional)
  /help             — this screen

  Live list + core|optional: config/roster.md (`bash scripts/bos-roster.sh`)

  💬  JUST TALK
  You don't need commands. Just type naturally:
  "plan my day" · "50 for lunch" · "how much did I spend"
  (A greeting like "hi" is not /morning and is not energy.)

  ⚙️  SETTINGS
  "turn off proactive mode" — agents stop suggesting
  "turn on proactive mode"  — agents suggest things
  "customize team"          — change agent taglines

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules
1. Only show agents from `profile.md → active_agents` (not the whole roster)
2. Only show command groups relevant to active packs:
   - DAILY RHYTHM → always shown
   - WORK → always shown; hide /ship and /follow-up without a Business pack
   - TRACKING → show /expense always, /workout only if Health pack
   - MEMORY & INBOX → always shown
   - SYSTEM → always shown
3. Language matches user's language from profile.md
4. Must fit on ONE screen — keep it tight
5. If profile.md doesn't exist → show generic version with all agents and all commands
