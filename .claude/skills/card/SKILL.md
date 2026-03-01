---
name: Profile Card
description: "Generate a shareable bOS profile card — screenshot-friendly stats about your system."
user_invocable: true
command: /card
---

# Profile Card

Generate a shareable, screenshot-friendly summary of the user's bOS stats.

## Protocol

### Step 1: Gather data

Read from state files and agent memory:
- `profile.md` → name, active_agents list, setup date (to calculate days active)
- `state/tasks.md` → total tasks completed (count all done entries)
- `state/habits.md` → current streak (longest active streak)
- Agent memory → session count per agent (top agent by conversations)
- `profile.md` → system_mode (Lite / Pro)

Calculate:
- **Active agents:** count of agents in `active_agents` list
- **Days active:** today's date minus profile creation date
- **Tasks completed:** total done tasks across all of tasks.md history
- **Streak:** current longest active streak from habits.md
- **Top agent:** agent with most interactions from memory
- **Mode:** Lite or Pro (from profile.md → system_mode)

### Step 2: Generate card

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🖥️ bOS  |  [Name]'s AI Team
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🤖 Active agents: [X]
  📅 Days active: [X]
  ✅ Tasks completed: [X]
  🔥 Streak: [X] days
  🏆 Top agent: @[name] ([X] conversations)
  📊 Mode: [Lite/Pro]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  github.com/zmrlk/bos
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3: Add context (optional)

After the card, optionally add 1 line:
"[Name]'s been using bOS for [X] days. Their system specializes in [primary_goal from profile]."

## Rules
- Only show numbers you HAVE data for. If tasks.md is empty → "Tasks completed: getting started"
- If days_active = 0 → "Day 1"
- Never fabricate stats
- Keep the card format exactly as specified — it's designed for screenshots
- The URL at the bottom is always `github.com/zmrlk/bos` (fixed, not pulled from data)
- If user asks for a copy-paste version → output as plain text block they can screenshot
