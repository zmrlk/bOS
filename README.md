# bOS — Your Personal Operating System

> 10 AI agents. 26 skills. Your life — business, health, growth, money — managed like a system.
>
> **v0.11.0** — Refit: 26 skills, 10 agents, hooks actually wired, no ritual interrogations.

---

## What It Looks Like

### Morning Briefing

```
☀️ @boss — Dzień dobry, Alex

┌─ 📋 PRIORITIES ─────────────────────────────────┐
│ 1. Client proposal (due tomorrow)                │
│ 2. Gym — leg day (Multisport)                    │
│ 3. Budget review (expenses +15% this month)      │
└──────────────────────────────────────────────────┘

┌─ 💰 BUFFER ──────────┐  ┌─ 🔥 STREAKS ─────────┐
│ 12 400 / 20 000 PLN  │  │ Gym: 5 days          │
│ ████████░░░░ 62%     │  │ Expenses: 12 days    │
│ +2 100 this month    │  │ Journal: 3 days      │
└──────────────────────┘  └──────────────────────┘

📅 10:00 Call with Tomek (Google Meet)
📅 14:00 Dentist (ul. Krakowska 15)
📧 3 unread — 1 from client (flagged), 2 newsletters

⏭️ Next step: Write the proposal intro (30 min, peak energy now)
```

### Dashboard (`/home`)

```
🏠 @boss — HOME

 Tasks    ██████████░░ 8/12 done this week
 Budget   ████████░░░░ 4 200 / 6 000 PLN remaining
 Energy   ████████████ 8/10 (peak hours now)
 Habits   🔥 gym 5d | 📝 journal 3d | 💰 expenses 12d
 Goals    ███░░░░░░░░░ 2/5 milestones hit

 ⚠️ Proposal deadline tomorrow — 2h estimated
 ✅ Invoice #12 paid (3 200 PLN)

⏭️ Start with the proposal — 90 min block?
```

### Ambient Capture (just talk naturally)

```
You: "wydałem 120 zł na lunch z klientem, byłem na siłowni,
      energia jakieś 7"

bOS: [responds to your actual question normally]

⏳ Logged: lunch 120 PLN (business), gym ✓, energy 7 (PM)
```

---

## Why bOS?

**You don't need another chatbot.** You need a system that knows your goals, tracks your money, manages your energy, and tells you what matters — without you having to ask.

bOS turns Claude Code into 10 specialized AI agents (plus conversational personas) that share context through state files, cross-agent signals, and lifecycle hooks. It's not a prompt. It's an operating system for ambitious people.

---

## What Makes bOS Different

**ADHD-First Design** — Max 5-8 lines per block. 15-25 min task chunks. Dopamine hooks (streaks, milestones). bOS picks FOR you to reduce decision fatigue.

**Energy > Time** — Tracks your energy daily. Matches tasks to your actual capacity, not just calendar slots.

**Financial Guard** — Every agent checks your budget before recommending anything. Buffer low? Conservative mode — system-wide.

**Ambient Capture** — Say "50 zl lunch" mid-conversation → logged. No commands needed.

**Session Memory** — `/wrap-up` saves where you left off. Next session picks up instantly.

**Self-Evolution** — `/evolve` audits agent performance, proposes improvements, checks alignment with your goals.

**Zero Config** — Say "hi" → 5-minute setup (mostly clicking) → it works.

---

## Quick Start

1. Install [Claude Code](https://claude.ai/code) (Pro $20/mo or Max $100/mo)
2. Download bOS: `git clone https://github.com/zmrlk/bos`
3. Open the bOS folder in Claude Code
4. Say "hi" — bOS guides you through setup

**That's it.** No API keys, no config files, no commands to memorize.

---

## Your Team

Ten agents have their own file, because each of them hands back an artifact — a plan, a design, a draft, an analysis. Roles that are purely conversational (ceo, coo, cfo, sales, product, wellness, mentor, teacher, organizer, investor) are **personas**: @boss wears them in the conversation instead of spawning a subagent that can't talk to you.

| Area | Agents | What they do |
|------|--------|-------------|
| 📊 **Business** | @cto, @cmo, @advocate | Tech decisions and code, marketing and GTM, devil's advocate |
| 🎨 **Design** | @design | Brand, mockups, UI/UX — owns every visual decision |
| 🧭 **Life** | @coach, @finance | Goals, habits, energy, personal budget and buffer |
| 💪 **Health** | @trainer, @diet | Training plans, meal plans and macros |
| 📚 **Learning** | @reader | Reading recommendations, book synthesis |
| 🤖 **Core** | @boss | Routes everything, carries the personas, system health |

---

## Daily Rhythm

```
/morning  →  Priorities + calendar + email (reads state first, doesn't interrogate)
/home     →  Dashboard — everything at a glance
/evening  →  Reflect + log the day + pick tomorrow's #1 (max 3 questions)
/wrap-up  →  Save session context for next time
```

Nothing here nags you. These run when you ask for them.

Or just talk: "good morning", "50 for lunch", "plan my day", "how much did I spend?"

---

## Skills (26 total)

| Skill | What it does |
|-------|-------------|
| `/morning` `/evening` | Daily bookends — briefing and shutdown, on demand |
| `/home` | Dashboard — everything at a glance |
| `/task` `/goal` | Manage tasks and long-term goals |
| `/decide` | Structured GO/NO-GO decisions |
| `/habit` | Streaks, milestones, quit tracker, workouts |
| `/log-expense` `/log-workout` | Quick logging — spending and training |
| `/reflect` | One-question micro-journal |
| `/remind` | Time-based push notifications (ntfy) |
| `/recall` | Search across past sessions |
| `/inbox` | AI email triage — Gmail + Outlook, noise filters |
| `/network` `/follow-up` | Contacts, follow-up timing and scripts |
| `/ship` | Review, commit, push |
| `/evolve` `/check` | Self-improvement audit and health check |
| `/connect` `/vault` `/schedule` | MCP connections, secrets, scheduled runs |
| `/build-agent` `/skill-creator` | Build your own agents and skills |
| `/setup` `/help` `/wrap-up` | Onboarding, command reference, session handoff |

<details>
<summary>All 26 skills →</summary>

`/build-agent` `/check` `/connect` `/decide` `/evening` `/evolve` `/follow-up` `/goal` `/habit` `/help` `/home` `/inbox` `/log-expense` `/log-workout` `/morning` `/network` `/recall` `/reflect` `/remind` `/schedule` `/setup` `/ship` `/skill-creator` `/task` `/vault` `/wrap-up`

</details>

---

## Superpowers (optional)

| Connection | What it unlocks |
|-----------|----------------|
| 📅 **Calendar** | Meeting previews in /morning, conflict detection |
| 📧 **Email** | Inbox triage, follow-up reminders |
| 🗄️ **Supabase** | Dashboards, analytics, multi-device sync |
| 📱 **Phone** | Remote Control (QR scan) or Telegram bot |

Connect with `/connect` — bOS walks you through it.

---

## Background Automations (optional, macOS)

bOS includes launchd crons for automated background tasks. These are **optional** — bOS works fine without them, but they add proactive notifications.

| Cron | Schedule | What it does |
|------|----------|-------------|
| `morning-push` | 07:30 daily | Push notification with today's priorities via ntfy |
| `email-monitor` | Every 15 min | Checks Gmail + Outlook for important emails, pushes via ntfy |

Both hard-fail without an ntfy topic configured, so an unconfigured install never publishes anything.

### Installation

Run the install script (macOS only):
```bash
bash .claude/hooks/install-layer3.sh
```

Or install manually:
```bash
cp com.bos.morning-push.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.bos.morning-push.plist
```

**Requirements:** ntfy app on phone + topic configured in `.secrets/ntfy.env`.

---

## How It Works

- **Local by default** — your data = markdown files on your machine
- **Always asks first** — explains what/why/where before scanning anything
- **You own everything** — just files in a folder. No lock-in.
- **Cross-agent signals** — when budget is tight, ALL agents know. When energy is low, tasks adapt.
- **Lifecycle hooks** — deterministic shell scripts inject context at session start/end. No AI guessing.

---

## Honest Limitations

bOS is powerful but it's important to know what it is and isn't:

- **Not a daemon.** bOS runs inside Claude Code sessions. It doesn't run in the background 24/7 (optional morning push via launchd is the exception).
- **Not true multi-agent.** It's one LLM with 10 specialized system prompts plus personas. Routing is prompt-based (~80% accurate), not code-enforced. @boss handles most work.
- **Not a mobile app.** Phone access works via Remote Control or Telegram, but it's not a native app.
- **Telemetry is improving.** Session counts tracked by hooks. Skill execution auto-logged to skill-runs.jsonl. Agent performance metrics improving.
- **Prompt-based features are best-effort.** Ambient capture, affect modulation, ADHD formatting — these work ~70-80% of the time, not 100%. They're prompt instructions, not code.
- **Data quality depends on you.** bOS can track expenses, habits, energy — but only if you actually mention them. Email triage (Gmail+Outlook) is automatic via cron.

---

## What's New in v0.11.0

- **Skills 65 → 26.** Everything that existed only as an aspiration is gone. `/quit` merged into `/habit` (one tracker: habits, cessation, workouts), the aspirational multi-channel `/inbox` replaced by the one that actually reads Gmail and Outlook.
- **Agents 19 → 10.** A file exists for a domain that hands back an artifact; purely conversational roles (ceo, coo, cfo, sales, product, wellness, mentor, teacher, organizer, investor) are now @boss personas. New: **@design** (owns every visual decision) and **@cmo** (marketing and GTM).
- **Hooks actually wired.** `protect-state.sh` (PreToolUse) and `tool-logger.sh` (PostToolUse) were documented but never connected to `settings.json`. They are now — state protection and telemetry are real, not a promise.
- **No more ritual interrogations.** `/morning` reads your state before it considers asking anything; `/evening` is capped at 3 questions; the time-aware hook lost eight directives that nagged about energy and offered rituals every session. Energy and expenses are still captured ambiently from what you say.
- **Numbers in the docs match the disk.** Skill and agent counts, hook wiring and cron list are generated from the actual tree, not from memory.

<details>
<summary>Previous versions →</summary>

**v0.10.0** — Proactive skill invocation, plugin routing, dual email (Gmail + Outlook), skill auto-tracking, project tracker.

**v0.9.2** — Tool memory (PostToolUse hook), Progressive Search, iMCP (8 macOS services), Skill outcome tracking, Hook profiling.

**v0.9.1** — /wrap-up, Ambient Detection, AskUserQuestion mandatory, Task Dependencies, time-aware hooks.

**v0.9.0** — Ambient bOS: time-aware hooks, proactive morning push, @advocate agent, affect modulation, ambient data capture, data gap detection, engagement tracking.

**v0.8.0** — Lifecycle hooks, Reflexion Protocol, Self-Evolution 2.0, telemetry, evening consolidation, agent intelligence upgrade.

**v0.7.0** — Circadian Engine, Smart Model Router, output modes, enhanced morning briefing, /connect skill.

**v0.6.1** — Unified Inbox, cron schedules, skill marketplace, hybrid sync.

**v0.5.0** — File date awareness, intelligent evolution, cross-agent signals.

</details>

---

## FAQ

**Do I need to know how to code?** No. bOS adapts to your tech comfort level.

**What does it cost?** Claude Pro ($20/mo) or Max ($100/mo). bOS itself is free and open source.

**What if I stop paying?** Your data stays — it's just files on your computer.

**Does it read my files?** Only file NAMES with your consent. Never contents.

**Is my data private?** Yes. Local by default. See [PRIVACY.md](PRIVACY.md) for full details.

---

*Built for ambitious people who want to run their life like a system.*
