---
name: Help
description: "Show all available commands, agents, and shortcuts. The go-to reference when users don't know what to do."
user_invocable: true
command: /help
---

# /help — What can I do?

Show a clean, one-screen reference of everything available.

**Adapt to tech_comfort:** "not technical" → simple language, group by action ("Chcesz zaplanować dzień?"). "I use apps" → list commands with brief descriptions. "I code" → compact table with command names.

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

  ⌨️  DAILY RHYTHM
  /morning (m)      — start your day
  /evening (e)      — end your day
  /home (h)         — dashboard

  📋  PLANNING
  /plan-week (p)    — plan the week (Sunday)
  /review-week (w)  — weekly review (Friday)
  /standup (s)      — team standup

  💰  TRACKING
  /expense (x)      — log spending
  /workout          — log exercise

  [Show BUSINESS commands only if Business pack active:]
  📊  BUSINESS
  /eval             — evaluate a project
  /card             — shareable profile card

  ⚙️  SYSTEM
  /scan             — learn about you (files)
  /check            — system health check
  /vault            — manage secrets/API keys
  /connect-mobile   — phone access via Telegram
  /build-agent      — create custom agent
  /export           — export all your data
  /delete-my-data   — delete all personal data
  /help             — this screen

  💬  JUST TALK
  You don't need commands. Just type naturally:
  "good morning" · "plan my day" · "50 zl lunch"
  "how much did I spend" · "I need a workout"

  ⚙️  SETTINGS
  "turn off proactive mode" — agents stop suggesting
  "turn on proactive mode"  — agents suggest things
  "customize team"          — change agent taglines

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Rules
1. Only show agents from `profile.md → active_agents` (not all 16)
2. Only show command groups relevant to active packs:
   - DAILY RHYTHM → always shown
   - PLANNING → always shown (if Life or Business pack)
   - TRACKING → show /expense always, /workout only if Health pack
   - BUSINESS → only if Business pack active
   - SYSTEM → always shown
3. Language matches user's language from profile.md
4. Must fit on ONE screen — keep it tight
5. If profile.md doesn't exist → show generic version with all agents and all commands
