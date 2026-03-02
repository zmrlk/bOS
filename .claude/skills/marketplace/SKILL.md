---
name: Skill Marketplace
description: "Browse, install, and manage bOS skills from the official registry. Community skills coming in v0.7.0."
user_invocable: true
command: /marketplace
---

# /marketplace — Skill Marketplace

Extend bOS with new skills. Browse the registry, install with one command.

---

## Usage

- `/marketplace` — browse available skills
- `/marketplace install [id]` — install a skill
- `/marketplace uninstall [id]` — remove an installed skill
- `/marketplace update` — update all installed marketplace skills
- `/marketplace search [query]` — search skills by name or category

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language, active_packs, active_agents, tech_comfort
- `skills-registry.json` (from GitHub if available, local fallback) → available skills
- `.claude/skills/` directory listing → installed skills
- `state/marketplace.md` → installed registry (if missing → create silently with schema from `state/SCHEMAS.md`)

### Step 2: Fetch registry

**Priority order:**
1. **GitHub fetch** (if connected): Fetch `skills-registry.json` from `zmrlk/bos` repo main branch
   ```bash
   git show origin/main:skills-registry.json 2>/dev/null
   ```
2. **Local fallback:** Read `skills-registry.json` from project root
3. **Offline:** Use cached version from last successful fetch (stored in agent memory)

---

### Subcommand: `/marketplace` (browse)

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🏪  MARKETPLACE — [X] skills available
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📦 Official Skills

  PRODUCTIVITY
  1. ✅ /pomodoro — Pomodoro Timer (installed)
  2. ⬜ /standup-async — Async Standup

  BUSINESS
  3. ⬜ /contract — Contract Generator
  4. ⬜ /pitch — Pitch Deck Builder

  HEALTH
  5. ⬜ /meal-plan — AI Meal Planner
  6. ⬜ /meditation — Guided Meditation

  LEARNING
  7. ⬜ /flashcard — Spaced Repetition
  8. ⬜ /exam-prep — Exam Preparation

  🔒 Community Skills — coming in v0.7.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Personalization:**
- Skills matching user's `active_packs` and `primary_goal` appear first
- Skills requiring MCPs the user already has → marked as "ready to install"
- Skills requiring missing MCPs → show requirement: "Requires: [MCP name]"

**Follow-up:** AskUserQuestion:
- "Install a skill" → ask which number
- "Search" → prompt for query
- "Done"

---

### Subcommand: `/marketplace install [id]`

1. **Find skill** in registry by ID
2. **Security scan:**
   - Read the SKILL.md content
   - Check for dangerous patterns: `rm `, `sudo`, `curl ` (to unknown URLs), `eval(`, secret/credential access
   - If `author_type = "official"` → trust, proceed
   - If `author_type = "community"` → show warning:
     ```
     ⚠️ Community skill — not officially reviewed.
     Author: [author]
     Security score: [X]/10

     Review the skill before installing?
     ```
     AskUserQuestion: "Install anyway" / "Review first" / "Cancel"
3. **Check requirements:**
   - `requires_mcp` → verify MCPs are available. If missing → "This skill needs [MCP]. /connect [MCP] to add it, then retry."
   - `compatible_agents` → verify agents are active
4. **Install:**
   - Fetch skill files from GitHub: `git checkout origin/main -- .claude/skills/[id]/`
   - Or if file included in registry → write to `.claude/skills/[id]/SKILL.md`
5. **Register:**
   - Add to `state/marketplace.md`: installed skills tracking
   - Update `profile.md → connected_mcps` if skill adds new capabilities
6. **Confirm:**
   ```
   ✅ /[command] installed!
   [description]

   Try it: /[command]
   ```

---

### Subcommand: `/marketplace uninstall [id]`

1. Find skill by ID
2. Confirm: "Remove /[command]? This deletes the skill files."
3. **Do NOT delete** built-in skills (those not from marketplace). Check `state/marketplace.md` for installation source.
4. Remove skill directory: `.claude/skills/[id]/`
5. Update `state/marketplace.md`
6. Confirm: "/[command] removed."

---

### Subcommand: `/marketplace update`

1. Fetch latest `skills-registry.json` from GitHub
2. Compare versions of installed marketplace skills
3. For each outdated skill:
   - Show: "[skill] [old] → [new]: [changelog summary]"
4. AskUserQuestion: "Update all" / "Pick which to update" / "Skip"
5. For each skill to update → re-fetch from GitHub, overwrite
6. Report: "Updated [X] skills."

---

### Subcommand: `/marketplace search [query]`

1. Search registry by: name, description, category, command, tags
2. Display matching skills (max 10)
3. Offer install for any result

---

## Security Validation

Before installing ANY skill, run this checklist:

| Check | Pass | Fail action |
|-------|------|-------------|
| No `rm` commands in SKILL.md | ✅ | Block install |
| No `sudo` commands | ✅ | Block install |
| No `curl`/`wget` to unknown URLs | ✅ | Warn + ask |
| No direct secret/credential access | ✅ | Block install |
| No `eval()` or dynamic code execution | ✅ | Warn + ask |
| `security_score` >= 8 | ✅ | Warn if < 8 |
| Author is `official` or verified | ✅ | Extra warning |

**Official skills (v0.6.0):** Always pass — they're from the bOS repo itself.
**Community skills (v0.7.0+):** Full scan + user review option.

---

## State File

`state/marketplace.md` — small file, read in full.

```markdown
# Marketplace — Installed Skills

| Skill ID | Command | Version | Installed | Source | Last updated |
|----------|---------|---------|-----------|--------|--------------|
| pomodoro | /pomodoro | 1.0.0 | 2026-03-02 | official | 2026-03-02 |
```

---

## Registry Format

Located at project root: `skills-registry.json`

```json
{
  "version": "0.6.0",
  "last_updated": "2026-03-02",
  "skills": [
    {
      "id": "skill-id",
      "name": "Human Readable Name",
      "version": "1.0.0",
      "author": "zmrlk",
      "author_type": "official",
      "category": "productivity|business|health|learning|system",
      "command": "/command",
      "description": "What this skill does",
      "security_score": 10,
      "requires_mcp": [],
      "compatible_agents": ["@agent"],
      "tags": ["keyword1", "keyword2"]
    }
  ]
}
```

---

## Integration with /evolve

Phase 0D in /evolve checks `skills-registry.json` for skills that match the user's profile but aren't installed. Surfaces them as recommendations alongside MCP suggestions.

---

## State Write Protocol

- **Owner:** @boss (marketplace.md)
- **Readers:** all agents, /evolve

---

## Cross-Agent Signals

### I POST when:
| Signal | Target | Priority | When |
|--------|--------|----------|------|
| `data:skill-installed` | @boss | normal | Skill installed successfully |
| `data:skill-uninstalled` | @boss | normal | Skill removed |
| `alert:skill-install-failed` | @boss, @cto | normal | Installation failed (security or fetch error) |

### I LISTEN for:
| Signal | From | Action |
|--------|------|--------|
| `/evolve` recommendations | @boss | Check skills-registry.json for matching skills |

---

## v0.6.0 Scope

- Official skills ONLY (from `zmrlk/bos` repo)
- No community submissions yet
- No skill rating/review system yet
- Community contributions → v0.7.0 (requires contributor guide + review process)
