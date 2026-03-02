# bOS — Your Personal Operating System

> One AI team for your whole life. Business. Health. Growth. Everything.

---

## What Is This?

bOS turns Claude into a team of personalized AI agents that manage your life, work, and growth. It's not a chatbot — it's an operating system for ambitious people.

**You open a folder, say hi, and it just works.** A quick setup (under 5 minutes) personalizes everything to YOU: your goals, your constraints, your personality.

---

## Requirements

- **[Claude Code](https://claude.ai/code)** — Claude's AI coding tool (CLI, desktop app, or VS Code extension)
  - Requires a Claude Pro ($20/mo) or Max ($100/mo) subscription from Anthropic
  - Think of it as the engine that powers bOS. You need both.
- That's it. Everything else is optional.

### Where to run bOS

| Environment | Best for | How to start |
|------------|----------|-------------|
| **Claude Code Desktop** | Everyone — the easiest way | Download the [desktop app](https://claude.ai/code), open it, select the bOS folder |
| **Terminal (CLI)** | Full power, advanced users | Open Terminal, type `claude`, press Enter |
| **VS Code / Cursor** | Developers, side-by-side editing | Install "Claude Code" extension from marketplace |

**Recommended for most people: Claude Code Desktop.** It's a regular app — no terminal needed. Just open it, select the bOS folder, and start talking.

All three options give you the same full bOS experience (all agents, all skills, all superpowers).

---

## Quick Start

1. Download bOS from [GitHub](https://github.com/zmrlk/bos)
2. Open the bOS folder in Claude Code
   *(Easiest: open Claude Code Desktop → select the bOS folder. Or in Terminal: type `claude`, drag the bOS folder in, press Enter.)*
3. Say "hi"
4. bOS introduces itself, asks your name, and guides you through setup (under 5 minutes, mostly clicking)

**That's it.** bOS explains everything along the way. No technical knowledge needed.

---

## Your Team

Pick what you need help with. bOS activates the right agents.

| Area | Agents | What they do |
|------|--------|-------------|
| 📊 **Business** | @ceo, @coo, @cto, @cfo, @cmo, @sales, @devlead | Strategy, decisions, sprint planning, tech, finances, marketing, sales, code quality |
| 🧭 **Life** | @coach, @organizer, @finance | Goals, journaling, daily planning, budgeting, decision journal |
| 💪 **Health** | @trainer, @diet, @wellness | Workouts, nutrition, habits, energy science, sleep & recovery |
| 📚 **Learning** | @teacher, @mentor, @reader | Learning roadmaps, career growth, networking CRM, reading |
| 🤖 **Always on** | @boss | Routes, orchestrates, webhooks, predictive nudges |

Plus: `/build-agent` to create any custom agent you need.

---

## What's New in v0.6.0

### Unified Inbox (/inbox)
Messages from Telegram, Email, Slack, Discord, and WhatsApp — all in one place. Route messages to agents, reply through the original channel. Works in Lite mode (local markdown) and Pro mode (Supabase). Auto-routing sends invoices to @cfo, meetings to @coo, bugs to @devlead.

### Cron Schedules (/schedule)
Automate your rituals. Schedule /morning, /evening, /standup, or any skill to run on a cron. Delivered via Telegram, email, or in-app (free, no n8n needed). @boss checks for overdue in-app schedules every session.

### Skill Marketplace (/marketplace)
Browse and install official bOS skills from the GitHub registry. 10 skills available at launch (pomodoro, contract, pitch, meal-plan, meditation, and more). Security validation before every install. Community skills coming in v0.7.0.

### Hybrid Sync (/sync)
Offline-first with cloud sync. Local files are always the fast source of truth. When Supabase is connected, changes push automatically. Conflict resolution: <5 min = auto-merge, >=5 min = you decide. Works transparently — agents don't need to know about sync.

### Post-Update Data Migration
After updates, bOS auto-fills new fields from existing data. What it can't figure out, it asks — with options to answer now, be reminded in 3 sessions, or skip forever. No more empty fields after version bumps.

### Webhook Events Expanded
New events: `message.received`, `message.replied`, `schedule.created`, `skill.installed`. Total: 17 webhook event types for n8n/Zapier/Make integration.

---

## What Was New in v0.5.0

### File Date Awareness
bOS checks how old your files are before making recommendations. Old project files won't trigger false suggestions. Active tools get priority.

### Intelligent Evolution (/evolve)
Profile-driven skill matching. `/evolve` audits your profile first, then suggests tools and skills that match who you are.

### Cross-Agent Signal System
22 mandatory signal types. Budget tight → ALL agents know. Stress high → @finance watches for impulse spending. Schedule fills up → alert before overcommit.

### Smarter UX, Subscriptions Discovery, Impact Assessment, Capacity Aggregation, Zero Permission Prompts
Generated options from your data (click > type). Benefit card detection. Every paid recommendation checked by @finance. All time commitments tracked across agents. Auto-configured permissions.

---

## Superpowers

bOS gets better with every tool you connect. These are optional — everything works without them, but each one unlocks new capabilities:

| Superpower | What it does | How to enable |
|-----------|-------------|---------------|
| 📁 **Files & Desktop** | Scan your files, organize, understand your projects | Enable Desktop Commander connector |
| 📅 **Calendar** | Morning briefings with today's meetings | Enable Google Calendar connector |
| 📧 **Email** | Triage, follow-ups, drafts, subscription detection | Gmail, Outlook, or any provider (IMAP) |
| 🗄️ **Database** | Dashboards, analytics, long-term tracking | Connect free Supabase account |
| 💻 **System Control** | Open apps, automate tasks on your Mac | Enable Control your Mac connector |
| 📝 **Notion** | Sync with your second brain | Enable Notion connector |

bOS auto-detects what's connected and adapts. No configuration needed.

---

## Phone Access

Two ways to use bOS from your phone:

### Remote Control (recommended)
Run `claude remote-control` in your terminal → scan the QR code with your phone → done. Full bOS access from the Claude app or claude.ai/code. Your computer needs to stay on.

### Telegram Bot
For 24/7 access (even when your computer is off). Say `/connect-mobile` after setup — bOS walks you through creating a Telegram bot step by step (~15 min).

**What works from your phone (both methods):**
- Morning and evening briefings
- Expense logging
- Task management
- Quick status checks
- Full agent conversations (Remote Control only)

---

## Daily Rhythm

| When | What | Command |
|------|------|---------|
| Morning | Priorities + quick win | `/morning` or just `m` |
| Anytime | Dashboard at a glance | `/home` or just `h` |
| Anytime | Deep work session | `/focus` or just `f` |
| Anytime | Talk to your agents | Just type |
| Evening | Reflect + plan tomorrow | `/evening` or just `e` |
| Evening | Micro-journal | `/reflect` or just `r` |
| Sunday | Plan the week | `/plan-week` or just `p` |
| Friday | Weekly review | `/review-week` or just `w` |
| Monthly | Budget review | `/budget` or just `b` |

You can also just talk naturally — say "good morning" and bOS starts your briefing. Say "50 zl lunch" and it logs the expense. No commands to memorize.

---

## All Commands

| Command | Shortcut | What it does |
|---------|----------|-------------|
| `/morning` | `m` | Morning briefing — priorities + quick win |
| `/evening` | `e` | Evening shutdown — reflect + plan tomorrow |
| `/home` | `h` | Dashboard — everything at a glance |
| `/plan-week` | `p` | Plan the week ahead |
| `/review-week` | `w` | Weekly review — what worked, what didn't |
| `/standup` | `s` | Team standup — all agents report in |
| `/goal` | `g` | Set, review, and track goals |
| `/task` | `t` | Manage tasks — add, complete, prioritize |
| `/expense` | `x` | Log an expense |
| `/focus` | `f` | Deep work session — pick a task, lock in, get it done |
| `/reflect` | `r` | Micro-journal — a daily question to reflect on |
| `/budget` | `b` | Build and manage your budget (50/30/20) |
| `/habit` | — | Track habits — streaks, milestones, personal bests |
| `/decide` | — | Decision journal — structured analysis + GO/NO-GO verdict |
| `/energy-map` | — | Visualize your energy patterns across the week |
| `/network` | — | Relationship CRM — track contacts and follow-ups |
| `/sprint` | — | Sprint planning — story points, velocity, burndown |
| `/money-flow` | — | Cash flow visualization — see where your money goes |
| `/webhooks` | — | Connect bOS to external tools (n8n, Zapier, Make) |
| `/learn-path` | — | AI learning roadmap — topic to mastery with milestones |
| `/workout` | — | Log a workout |
| `/eval` | — | Evaluate a project opportunity |
| `/scan` | — | Scan your computer to learn about you |
| `/vault` | — | Manage passwords and API keys securely |
| `/check` | — | System health check |
| `/card` | — | Generate a shareable profile card |
| `/export` | — | Export all your data |
| `/delete-my-data` | — | Delete all personal data |
| `/inbox` | `in` | Unified inbox — messages from all channels |
| `/schedule` | `sc` | Schedule skills to run automatically |
| `/marketplace` | `mp` | Browse and install skills from registry |
| `/sync` | `sy` | Sync local data with cloud |
| `/connect-mobile` | — | Set up phone access via Telegram |
| `/build-agent` | — | Create a custom agent |
| `/evolve` | — | Self-improve — discover new tools and capabilities |
| `/code` | `c` | Code pipeline — write, review, secure, ship |
| `/analyze` | `a` | Data analysis — CSV, JSON, pipeline stats |
| `/invoice` | `i` | Invoice management — create, track, remind |
| `/timetrack` | `tt` | Time tracking — start, stop, log, report |
| `/proposal` | — | Generate personalized client proposals |
| `/design` | — | Design briefs, social media content, brand check |
| `/verify` | — | Pipeline data verification and enrichment |
| `/competitive` | — | Competitive analysis — pricing, positioning, threats |
| `/repurpose` | — | Content repurposing — one piece → all platforms |
| `/help` | — | Show available commands and agents |
| `/setup` | — | Guided onboarding (runs automatically on first use) |

Or just talk naturally — "good morning", "50 zl lunch", "plan my day" all work.

---

## How It Works

- **Works locally by default** — your core data stays on your machine in simple markdown files you control
- **Always asks first** — bOS explains what it wants to do and asks for consent before scanning your files or checking anything. No surprises.
- **Optional cloud services** — connect Supabase (database), Google Calendar, email, or other services for extra capabilities. When connected, data flows through those services. You control what you connect.
- **Agents remember you** — persistent memory across sessions
- **Gets smarter over time** — every conversation teaches your agents more about you
- **You own everything** — it's just files in a folder. No lock-in. No subscription.
- **Your data is private** — without optional cloud services, everything stays on your computer. When you connect services like Supabase or Gmail, only the data needed for that service is shared. You can disconnect anytime.
- **Zero permission prompts** — bOS pre-configures Claude Code to auto-approve safe operations (file reading, editing, MCP tools). You see what's happening at every step, but you're never interrupted to click "approve". Destructive commands (like `rm -rf`) are always blocked.
- **Cross-agent intelligence** — agents share context through mandatory signals. Your trainer knows about your diet. Your finance advisor knows about stress patterns. Everything connects.
- **Phone access** — optionally connect Telegram to use bOS from your phone (say `/connect-mobile` after setup)

---

## Updating bOS

bOS updates itself automatically. When a new version is available:

1. Open bOS as usual
2. bOS tells you: "bOS [version] dostępny. Powiedz 'zaktualizuj'."
3. Say "zaktualizuj" (or "update")
4. Done

Your data (profile, tasks, finances, habits, goals) is never touched — only the system files (agents, skills) get updated. A backup is created automatically before every update.

---

## Thank You

You have the full version of bOS. Everything included:
- 17 agents + custom agent builder
- 49 skills (including /inbox, /schedule, /marketplace, /sync)
- Unified inbox — all channels in one place
- Cron schedules — automate any skill
- Skill marketplace — install new skills from registry
- Hybrid sync — offline-first with cloud backup
- Full code pipeline (/code — write, review, secure, ship)
- Professional tools (/invoice, /timetrack, /proposal, /competitive, /analyze)
- Content engine (/design, /repurpose — one piece → all platforms)
- Agent collaboration (Structured Debate protocol)
- Cross-agent signal system (22 mandatory signals)
- 17 webhook event types (n8n, Zapier, Make)
- Capacity aggregation across all life domains
- Intelligent self-evolution with profile-driven skill matching
- Predictive nudges (energy crash prediction, proactive load reduction)
- Cloud database support (optional, auto-detected)
- Post-update data migration (smooth version upgrades)
- All future updates

Need help? Type `/help` in bOS or visit our community.

---

## FAQ

**Do I need to know how to code?**
No. bOS works through conversation — you just talk to it. During setup, bOS asks about your tech comfort level and adapts everything accordingly.

**Can I use bOS from my phone?**
Yes — two ways. The easiest is Remote Control: run `claude remote-control` in your terminal, scan the QR code, and you have full bOS access from the Claude app. Or connect a Telegram bot for 24/7 access — say `/connect-mobile` after setup.

**Does bOS scan my files without asking?**
No. bOS always explains what it wants to check, where, and why — then asks for your consent. It only looks at file and folder names, never opens or reads your documents.

**What does Claude Code cost?**
Claude Code requires a Claude Pro ($20/mo) or Max ($100/mo) subscription from Anthropic. The desktop app, terminal CLI, and VS Code extension are all free — you just need the subscription.

**How do I get updates?**
Automatically. Open bOS — it checks for updates and asks if you want to install. Say "zaktualizuj" and it's done. Your data stays safe.

**What happens if I cancel Claude Code?**
Your data stays safe — it's just files on your computer. You can still read everything in the `state/` folder with any text editor. You just won't be able to talk to your agents until you resubscribe. Nothing is lost.

---

**What are webhooks?**
bOS can notify external tools (like n8n, Zapier, or Make) when things happen — task completed, budget exceeded, habit milestone hit. Say `/webhooks` to set it up. Completely optional.

**What's a sprint?**
If you like structured productivity, `/sprint` adds story points and velocity tracking to your weekly planning. Think Scrum, but for your personal life. Optional — everything works without it.

---

*Built for ambitious people who want to run their life like a system.*
