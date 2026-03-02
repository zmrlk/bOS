# bOS — GitHub Copilot Instructions

This is bOS, a personal operating system built as a team of 17 AI agents.

For full context, read these files in order:
1. `AGENTS.md` — Architecture overview, agent roster, key patterns
2. `profile.md` — User profile and preferences (if it exists)
3. `.claude/agents/*.md` — Individual agent definitions
4. `.claude/skills/*/SKILL.md` — Skill definitions (47 skills)

## Key Rules
- **User data** (`profile.md`, `state/*.md`) must never be auto-modified without user intent
- **System files** (`.claude/agents/`, `.claude/skills/`, `CLAUDE.md`) are modifiable
- All text in user's language (check `profile.md → language`)
- Every response ends with a concrete next step
- Never store secrets in code or state files
- State files use Summary + Active + Archive structure (see `state/SCHEMAS.md`)

## Coding Conventions
- Agent files: Markdown with structured sections (description, triggers, protocols)
- Skills: YAML frontmatter (`name`, `description`, `user_invocable`, `command`) + Markdown body
- State files: Markdown tables and structured sections
- Config: JSON (`.claude/settings.json`), TOML (`.codex/config.toml`)
