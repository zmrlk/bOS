# bOS — Your Personal Operating System

> 17 AI agents. One team. Your whole life — business, health, growth, money — managed like a system.

---

## Why bOS?

**You don't need another chatbot.** You need a system that knows your goals, tracks your money, manages your energy, and tells you what matters — without you having to ask.

bOS turns Claude into a team of 17 specialized AI agents that work together. They share context, learn from your patterns, and evolve over time. It's not a prompt. It's an operating system for ambitious people.

---

## What Makes bOS Different

### Your Team Knows Each Other
When your stress is high for 3 days, your finance agent automatically watches for impulse spending. When your budget is tight, ALL agents stop recommending paid tools. When your trainer schedules a workout, your planner blocks the time. **22 mandatory cross-agent signals** keep everyone in sync.

### It Learns From Its Own Mistakes
Every agent stores reflections on what went wrong. Next time a similar task comes up, it loads those lessons first. After enough failures, bOS generates a **prompt patch** — a targeted fix to the agent's behavior — and asks you to approve it. It can even roll back changes that don't work.

### Morning Briefing That Actually Matters
Not "here's a to-do list." Your morning includes: today's calendar, email triage, newsletter digest, energy-matched task suggestions, financial buffer status, habit streaks, and proactive warnings. All personalized. All in 30 seconds.

### ADHD-First Design
Max 5-8 lines per block. 15-25 minute task chunks. Dopamine hooks (streaks, challenges, milestones). Max 3 visible tasks at a time. bOS picks FOR you to reduce decision fatigue. Built by someone who gets it.

### Energy Science, Not Time Management
bOS tracks your energy, sleep, and mood daily. After a week, it knows your patterns — best day for deep work, worst day for decisions, what exercise does to your focus. Tasks get matched to energy, not just calendar slots.

### Financial Buffer Protection
Every agent checks your budget before recommending anything. Buffer below target? Conservative mode activates across the entire system. Impulse spending detected? Your wellness agent gets notified. No agent operates in a financial vacuum.

### Self-Evolution
bOS improves itself monthly. It audits agent performance, discovers new tools, detects repeated patterns and turns them into skills, verifies security of all connections, and measures its own impact. Every change passes an alignment check against your goals.

### Sleep-Time Intelligence
When you say goodnight, bOS keeps working in the background — consolidating today's patterns, pre-generating tomorrow's morning brief, detecting energy correlations. You wake up to faster, smarter briefings.

### Zero Configuration
Say "hi" → 5-minute setup (mostly clicking) → it works. No API keys to paste, no config files to edit, no commands to memorize. Just talk naturally: "good morning", "50 zl lunch", "plan my day."

---

## Requirements

- **[Claude Code](https://claude.ai/code)** — Claude's AI coding tool (CLI, desktop app, or VS Code extension)
  - Requires a Claude Pro ($20/mo) or Max ($100/mo) subscription from Anthropic
- That's it. Everything else is optional.

### Where to Run bOS

| Environment | Best for | How to start |
|------------|----------|-------------|
| **Claude Code Desktop** | Everyone — the easiest way | Download the [desktop app](https://claude.ai/code), open it, select the bOS folder |
| **Terminal (CLI)** | Full power, advanced users | Open Terminal, type `claude`, press Enter |
| **VS Code / Cursor** | Developers, side-by-side editing | Install "Claude Code" extension from marketplace |

**Recommended for most people: Claude Code Desktop.** It's a regular app — no terminal needed.

---

## Quick Start

1. Download bOS from [GitHub](https://github.com/zmrlk/bos)
2. Open the bOS folder in Claude Code
3. Say "hi"
4. bOS introduces itself, asks your name, and guides you through setup (under 5 minutes, mostly clicking)

**That's it.** bOS explains everything along the way. No technical knowledge needed.

---

## Your Team

| Area | Agents | What they do |
|------|--------|-------------|
| 📊 **Business** | @ceo, @coo, @cto, @cfo, @cmo, @sales, @devlead | Strategy, sprint planning, tech decisions, business finances, marketing, sales scripts, code quality pipeline |
| 🧭 **Life** | @coach, @organizer, @finance | Goal tracking, decision journal, daily planning, personal budgeting, habit building |
| 💪 **Health** | @trainer, @diet, @wellness | Personalized workouts, meal planning, energy science, sleep tracking, stress management |
| 📚 **Learning** | @teacher, @mentor, @reader | Learning roadmaps, career strategy, networking CRM, book recommendations |
| 🤖 **Always on** | @boss | Routes everything, orchestrates multi-agent responses, predictive nudges, system health |

Plus: `/build-agent` to create any custom agent you need.

---

## What's New in v0.8.0

### Lifecycle Hooks
Deterministic shell scripts that inject context at session start (today's tasks, budget status, critical signals), preserve state before compaction, and batch-update telemetry at session end. Your agents never lose context.

### Reflexion Protocol
Every agent learns from failures. Structured reflections stored per agent, loaded before similar tasks. 3+ failures trigger automatic prompt patches with before/after evidence — all user-approved, with auto-rollback safety net.

### Self-Evolution 2.0 (/evolve)
Five-phase evolution cycle: system health audit → agent intelligence tuning (reflexion analysis, prompt patches, routing optimization) → skill evolution → impact measurement → fresh data delivery. Every proposal passes an Objective Kernel — 6-point alignment check against your goals.

### Telemetry System
Agent performance tracking: invocations, success rates, routing accuracy, skill usage. Internal metrics that power smarter evolution and surface in weekly reviews. You never see raw data — only insights.

### Sleep-Time Consolidation
After your evening shutdown, bOS silently consolidates daily patterns, detects energy correlations, and pre-generates tomorrow's morning brief. Wake up to a faster, smarter system.

### Agent Intelligence Upgrade
All 17 agents enriched with frontmatter: model routing (haiku for quick ops, sonnet for analysis), turn limits, permission boundaries, skill associations, and the Reflexion Protocol. Smarter, faster, more secure.

### Skill Optimization
12 skills optimized with model selection (haiku for logging, sonnet for analysis), context isolation for heavy operations, and tool restrictions for privacy-sensitive skills.

---

## Previous Versions

<details>
<summary>v0.7.0 — Circadian Engine</summary>

- **Circadian Engine** — 4 modes (STRATEGIST/EXECUTOR/PHILOSOPHER/MAINTAINER) based on time of day and energy
- **Smart Model Router** — automatic model selection by task complexity
- **Minimal Context Injection** — each agent gets only the profile fields it needs
- **Output Modes** — MINIMAL/DETAILED/VISUAL/VOICE auto-detected
- **World Insights** — AI-generated background intelligence in /morning
- **Enhanced Morning Briefing** — newsletters, email triage, calendar preview
- **/connect Skill** — full MCP lifecycle management
- **Sequential Thinking** — structured reasoning for complex tasks

</details>

<details>
<summary>v0.6.1 — Unified Inbox</summary>

- Unified Inbox (/inbox) — all messages in one place
- Cron Schedules (/schedule) — automate any skill
- Skill Marketplace (/marketplace) — install from registry
- Hybrid Sync (/sync) — offline-first with cloud backup
- Post-Update Data Migration + 17 Webhook Events

</details>

<details>
<summary>v0.5.0 — Intelligent Evolution</summary>

- File Date Awareness — old files don't trigger false suggestions
- Intelligent Evolution (/evolve) — profile-driven skill matching
- 22 Cross-Agent Signals — budget, stress, capacity, energy
- Subscriptions Discovery, Impact Assessment, Zero Permission Prompts

</details>

---

## Superpowers

Optional connections that make bOS smarter:

| Superpower | What it unlocks |
|-----------|----------------|
| 📁 **Files & Desktop** | Scan your files, organize, understand your projects |
| 📅 **Calendar** | Morning briefings with today's meetings, conflict detection |
| 📧 **Email** | Inbox triage, follow-ups, subscription detection |
| 🗄️ **Database** | Dashboards, analytics, long-term tracking, multi-device sync |
| 💻 **System Control** | Open apps, automate tasks on your Mac |
| 📝 **Notion** | Sync with your second brain |

bOS auto-detects what's connected and adapts. No configuration needed.

---

## Phone Access

### Remote Control (recommended)
Run `claude remote-control` in your terminal → scan the QR code → full bOS from your phone. Computer needs to stay on.

### Telegram Bot
24/7 access even when computer is off. Say `/connect-mobile` — bOS walks you through it (~15 min).

---

## Daily Rhythm

| When | What | Command |
|------|------|---------|
| Morning | Priorities + energy check + quick win | `m` |
| Anytime | Dashboard at a glance | `h` |
| Anytime | Deep work session | `f` |
| Evening | Reflect + plan tomorrow | `e` |
| Sunday | Plan the week | `p` |
| Friday | Weekly review with telemetry | `w` |

Or just talk: "good morning", "50 zl lunch", "plan my day", "how much did I spend this week."

---

## All 49 Skills

<details>
<summary>Click to expand full command list</summary>

| Command | Shortcut | What it does |
|---------|----------|-------------|
| `/morning` | `m` | Morning briefing — priorities, calendar, email, energy |
| `/evening` | `e` | Evening shutdown — reflect, log, plan tomorrow |
| `/home` | `h` | Dashboard — everything at a glance |
| `/plan-week` | `p` | Plan the week ahead |
| `/review-week` | `w` | Weekly review with telemetry insights |
| `/standup` | `s` | All agents report in |
| `/goal` | `g` | Set and track goals |
| `/task` | `t` | Manage tasks |
| `/expense` | `x` | Log an expense |
| `/focus` | `f` | Deep work session timer |
| `/reflect` | `r` | Micro-journal |
| `/budget` | `b` | Budget builder (50/30/20) |
| `/code` | `c` | Code pipeline — write, review, secure, ship |
| `/analyze` | `a` | Data analysis — CSV, JSON, pipeline |
| `/invoice` | `i` | Invoice management |
| `/timetrack` | `tt` | Time tracking |
| `/inbox` | `in` | Unified inbox — all channels |
| `/schedule` | `sc` | Automate skills with cron |
| `/marketplace` | `mp` | Browse and install skills |
| `/sync` | `sy` | Sync with cloud |
| `/habit` | — | Streaks, milestones, personal bests |
| `/decide` | — | Decision journal with GO/NO-GO verdict |
| `/energy-map` | — | Visualize energy patterns |
| `/network` | — | Relationship CRM |
| `/note` | `n` | Quick capture — notes, reminders, ideas |
| `/sprint` | — | Sprint planning with velocity |
| `/money-flow` | — | Cash flow waterfall chart |
| `/learn-path` | — | AI learning roadmap |
| `/proposal` | — | Client proposal generator |
| `/competitive` | — | Competitive analysis |
| `/design` | — | Design briefs, social content |
| `/repurpose` | — | One piece → all platforms |
| `/verify` | — | Pipeline data enrichment |
| `/webhooks` | — | Connect to n8n/Zapier/Make |
| `/workout` | — | Log a workout |
| `/evolve` | — | Self-improve — discover, learn, optimize |
| `/connect` | `cn` | Manage tool connections |
| `/connect-mobile` | — | Phone access setup |
| `/build-agent` | — | Create a custom agent |
| `/scan` | — | Scan your computer (with consent) |
| `/vault` | — | Manage API keys securely |
| `/proactive-check` | — | Silent session-start nudges |
| `/project-eval` | — | Go/No-Go project scoring |
| `/check` | — | System health check |
| `/card` | — | Shareable profile card |
| `/export` | — | Export all data |
| `/delete-my-data` | — | Delete everything |
| `/help` | — | Show commands and agents |
| `/setup` | — | Guided onboarding |

</details>

---

## How It Works

- **Local by default** — your data stays on your machine in markdown files you control
- **Always asks first** — explains what, why, where before scanning anything
- **Optional cloud** — connect Supabase for dashboards and multi-device sync
- **Zero permission prompts** — pre-configured to auto-approve safe operations
- **Cross-agent intelligence** — 22 signal types keep all agents in sync
- **Self-evolving** — monthly evolution cycles with alignment-checked improvements
- **You own everything** — just files in a folder. No lock-in. No subscription beyond Claude Code.

---

## Updating

1. Open bOS
2. bOS tells you: "New version available"
3. Say "update"
4. Done — your data is never touched

---

## FAQ

**Do I need to know how to code?**
No. bOS works through conversation. It adapts to your tech comfort level automatically.

**Can I use it from my phone?**
Yes — Remote Control (scan QR, instant access) or Telegram bot (always-on, even when computer is off).

**What does it cost?**
Claude Pro ($20/mo) or Max ($100/mo) from Anthropic. bOS itself is free and open source.

**What if I stop paying?**
Your data stays safe — it's just files on your computer. Everything is readable with any text editor.

**Does it read my files?**
Only with explicit consent. It scans file NAMES (not contents) to understand your tools and projects.

---

*Built for ambitious people who want to run their life like a system.*
