# bOS — Personal Operating System

> Universal agent instructions for any AI coding platform.
> For Claude Code-specific behavior, see `CLAUDE.md`.

---

## What is bOS

bOS is a personal operating system — a team of 17 specialized AI agents that manage a user's life, work, and growth. It runs as a persistent project with local state files, agent memory, and cross-agent coordination.

**Primary platform:** Claude Code (CLI / Desktop / VS Code).
**This file** provides enough context for any AI agent (Codex, Gemini, Cursor, Copilot, Windsurf) to understand and work with the codebase.

---

## Architecture

```
bos/
├── CLAUDE.md                  # Claude Code instructions (source of truth)
├── AGENTS.md                  # Cross-platform instructions (this file)
├── GEMINI.md                  # → symlink to AGENTS.md
├── profile.md                 # User profile (created during /setup)
├── profile-template.md        # Template for new users
├── VERSION                    # Current version (semver)
├── skills-registry.json       # Skill catalog metadata
│
├── .claude/                   # Claude Code config
│   ├── agents/                # 17 agent definitions (*.md)
│   ├── skills/                # 47 skills (*/SKILL.md)
│   └── settings.json          # Permission allowlist
│
├── .agents/                   # Antigravity-compatible mirror
│   └── skills/                # → symlinks to .claude/skills/*
│
├── .codex/                    # OpenAI Codex config
│   └── config.toml
│
├── state/                     # User state (operational data)
│   ├── tasks.md               # Daily/weekly tasks
│   ├── finances.md            # Income, expenses, buffer
│   ├── habits.md              # Habit tracking, streaks
│   ├── goals.md               # Long-term goals
│   ├── daily-log.md           # Energy, sleep, mood
│   ├── decisions.md           # Key decisions with reasoning
│   ├── context-bus.md         # Cross-agent signals
│   ├── weekly-log.md          # Weekly review entries
│   ├── pipeline.md            # Leads, clients (business)
│   ├── projects.md            # Active projects
│   ├── invoices.md            # Invoice tracking
│   ├── time-log.md            # Project time entries
│   ├── inbox.md               # Unified message inbox
│   ├── journal.md             # Micro-journal
│   ├── network.md             # Relationship CRM
│   ├── schedules.md           # Cron schedules
│   ├── marketplace.md         # Installed skills
│   ├── SCHEMAS.md             # File format documentation
│   └── archive/               # Archived old entries
│
├── supabase/                  # Pro mode database schemas
├── templates/                 # n8n workflow templates
├── README.md                  # User-facing documentation
└── PRIVACY.md                 # Privacy policy
```

---

## Agent Roster

17 agents, each with a dedicated domain. Defined in `.claude/agents/*.md`.

| Agent | File | Domain |
|-------|------|--------|
| @boss | boss.md | Orchestrator — routing, synthesis, system ops |
| @ceo | ceo.md | Strategy, decisions, vision |
| @coo | coo.md | Operations, planning, accountability |
| @cto | cto.md | Tech, architecture, tools |
| @cfo | cfo.md | Business finances, pricing, invoicing |
| @cmo | cmo.md | Content, branding, marketing |
| @sales | sales.md | Pipeline, leads, sales scripts |
| @finance | finance.md | Personal money, budget, saving |
| @coach | coach.md | Life goals, motivation, habits |
| @organizer | organizer.md | Daily planning, errands, routines |
| @wellness | wellness.md | Sleep, stress, recovery |
| @trainer | trainer.md | Workouts, fitness, exercise |
| @diet | diet.md | Nutrition, meal plans, food |
| @mentor | mentor.md | Career growth, networking |
| @teacher | teacher.md | Learning, skills, education |
| @reader | reader.md | Books, reading recommendations |
| @devlead | devlead.md | Code writing, review, security, quality |

**Routing:** User mentions `@agent` → delegate. No mention → match intent to best agent. Ambiguous → @boss picks one.

---

## Skills (47)

Skills are invocable commands (e.g., `/morning`, `/task`, `/budget`). Each lives in `.claude/skills/<name>/SKILL.md` with YAML frontmatter:

```yaml
---
name: Skill Name
description: "When to use this skill"
user_invocable: true
command: /skillname
---
# Instructions follow in Markdown
```

**Key skills:** `/morning` (daily briefing), `/evening` (shutdown), `/home` (dashboard), `/task` (manage tasks), `/goal` (set goals), `/setup` (onboarding), `/check` (system health), `/code` (code pipeline), `/budget` (finances), `/focus` (deep work timer).

Full list: see `skills-registry.json` or run `/help`.

---

## State Files

All user data lives in `state/*.md`. Growing files use a **Summary + Active + Archive** structure:
- **Summary** (first ~25 lines): metrics, counters, metadata
- **Active**: current month's entries
- **Archive**: `state/archive/` for older data

**Key conventions:**
- Each file has designated owners (agents that can write) and readers
- Read the Summary section for quick context; read Active only when needed
- Never delete another agent's entries
- `profile.md` is the user identity source of truth — semi-static, survives updates

---

## Key Patterns

1. **Action bias** — Execute first, narrate after. Don't ask when you can act.
2. **Every response ends with a next step** — concrete, actionable, ≤30 min.
3. **Language = user's language** — respond in whatever language the user writes in.
4. **Energy > time** — match tasks to energy levels, not just time slots.
5. **Protect the buffer** — check finances before recommending spending.
6. **Progressive profiling** — learn about the user from conversations, don't interrogate.
7. **Context bus** — agents share findings via `state/context-bus.md` signals.
8. **Never store secrets** — passwords/keys go to `/vault`, never to memory or files.
9. **Never persist crisis data** — mental health conversations are ephemeral.

---

## Working With This Codebase

**If you're an AI agent on another platform:**
- Read `profile.md` to understand the user
- Read `state/tasks.md` (Summary section) for current priorities
- Agent files in `.claude/agents/` explain each agent's personality and rules
- SKILL.md files are self-documenting — read any skill to understand it
- `CLAUDE.md` has the full behavioral specification (Claude Code-specific)
- `state/SCHEMAS.md` documents all state file formats

**If you're modifying code:**
- System files: `.claude/agents/`, `.claude/skills/`, `CLAUDE.md`, `AGENTS.md`
- User data (NEVER auto-modify): `profile.md`, `state/*.md`
- Test changes: run `/check` after modifications
