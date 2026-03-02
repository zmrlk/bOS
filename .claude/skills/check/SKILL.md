---
name: bOS Health Check
description: "Verify that bOS is working correctly. Check profile, state files, agents, and connected superpowers."
user_invocable: true
command: /check
---

# bOS — Health Check

## What This Does
Runs a quick diagnostic of your bOS installation. Checks that everything is working and tells you if something needs attention.

**Adapt to tech_comfort:** "not technical" → "Połączenia: Pliki ✅, Kalendarz ❌" (friendly names). "I use apps" → name tools: "Desktop Commander ✅". "I code" → show MCP IDs, config paths.

## Protocol

### 1. Profile Check
- Read `profile.md`
- Verify it exists and has real data (not just template)
- Check required fields: name, active_packs, active_agents, primary_goal
- Report: ✅ Profile OK or ❌ Profile issue: [what's missing]

### 2. State Files Check
Based on active_packs from profile, verify state files exist:
- Always: `state/tasks.md`, `state/decisions.md`, `state/weekly-log.md`, `state/goals.md`, `state/daily-log.md`, `state/context-bus.md`
- Business: `state/finances.md`, `state/pipeline.md`, `state/projects.md`, `state/invoices.md`, `state/time-log.md`
- Life/Health: `state/habits.md`
- Life (if /reflect used): `state/journal.md`
- Life (if /network used): `state/network.md`
- Infrastructure: `state/archive/`, `state/.backup/`, `state/.maintenance-log.md`, `state/.webhooks.md` (if webhooks configured)
- Report: ✅ State files OK or ❌ Missing: [list]

### 3. Superpowers Check
Re-run MCP detection (same as setup Step 2):
- Try each connector silently
- Compare with `connected_mcps` from profile.md
- Report changes: "Calendar was connected, now it's not" or "New: Email is now connected!"
- Update profile.md if changed

### 3B. Discovery Offer (after Superpowers Check)

If any superpowers are ❌ OR user has tools detected in profile without corresponding MCP:

Use `AskUserQuestion`:
- header: "Discovery"
- question: "Masz niepodłączone narzędzia. Chcesz, żebym przeszukał internet w poszukiwaniu sprawdzonych rozszerzeń?"
- options:
  - "Szukaj rozszerzeń w internecie" (description: "Przeszukam Reddit, GitHub i agregatory MCP")
  - "Nie trzeba" (description: "Kontynuuj health check")

**If "Szukaj rozszerzeń"** → run the same discovery flow as setup Step 5C:
1. Batch WebSearch queries based on missing superpowers and user's tools
2. Filter through security checklist (≥50 stars, recent commits, open source, positive reviews, no root access, clear permissions)
3. Show max 3 verified results adapted to tech_comfort
4. Offer installation with user confirmation
5. Update profile.md → connected_mcps after installation

**If "Nie trzeba"** → continue to Agent Check.

### 4. Agent Check
- List active agents from profile
- Verify each agent file exists in `.claude/agents/`
- Report: ✅ [X] agents active or ❌ Missing agent file: [name]

### 5. State File Integrity Check

#### State File Content Validation
After confirming files exist, validate STRUCTURE:
1. Read each state file
2. Check for required schema elements (per state/SCHEMAS.md):
   - tasks.md: Has at least one ## YYYY-MM-DD section header + table
   - daily-log.md: Has table header row with correct columns
   - habits.md: Has table header row
   - weekly-log.md: Has at least one ## Week section
   - finances.md: Has Budget and Buffer sections
   - goals.md: Has Active Goals section
   - context-bus.md: Can be empty (valid)
3. If structure is invalid:
   - Show: "⚠️ [filename] — format uszkodzony. Naprawiam..."
   - Backup corrupted file to state/.backup/[filename]-corrupted-[date].md
   - Recreate with correct schema headers from SCHEMAS.md
   - If any data was recoverable → migrate to new file
4. Show results:
   ```
   📁 State files:
   ✅ tasks.md — OK (12 tasks)
   ✅ daily-log.md — OK (7 entries)
   ⚠️ habits.md — naprawiony (3 habits recovered)
   ✅ finances.md — OK
   ```

- For each state file that exists → verify it has valid headers/table structure
- Check for corruption: orphaned rows, missing columns, broken markdown tables
- Report: ✅ State files healthy or ⚠️ [file] may need repair: [issue]
- Auto-repair if possible (add missing headers, fix table alignment)

### 5B. Cross-Platform Files Check
- Verify cross-platform instruction files exist:
  - `AGENTS.md` — cross-platform architecture brief
  - `GEMINI.md` — symlink to AGENTS.md (for Google Antigravity)
  - `.cursorrules` — Cursor IDE instructions
  - `.windsurfrules` — Windsurf/Codeium instructions
  - `.github/copilot-instructions.md` — GitHub Copilot instructions
  - `.codex/config.toml` — OpenAI Codex configuration
  - `.agents/skills/` — symlinked skills directory (for Antigravity)
- Verify GEMINI.md is a symlink to AGENTS.md (not a copy)
- Verify `.agents/skills/` contains symlinks matching `.claude/skills/` entries
- Report: ✅ Cross-platform files OK or ❌ Missing: [list]

### 6. System Health
- **Maintenance check:** Read `state/.maintenance-log.md`. If last maintenance was 30+ days ago OR file is empty/has zero entries → "⚠️ Maintenance overdue. Run /morning to trigger monthly cleanup."
- **Backup check:** Check `state/.backup/` for profile backups. Report: "Last backup: [date]" or "⚠️ No profile backup found."
- **Version check:** Compare `VERSION` file with `profile.md → bos_version`. If different → "⚠️ Version mismatch: file says [X], profile says [Y]. Updating..."
- **Context-bus check:** Count entries in context-bus.md. If >10 expired entries → "⚠️ Context-bus needs cleanup ([X] expired entries)."
- **Invoices check:** If state/invoices.md exists → validate table structure, check for overdue invoices (status != paid AND due date < today). Report: "🧾 [N] invoices, [M] overdue" or "✅ No overdue invoices."
- **Time-log check:** If state/time-log.md exists → validate Summary/Active/Archive structure, check for orphaned active timer (running for 24+ hours). Report: "⏱️ Time log OK ([N] entries)" or "⚠️ Active timer running for [X]h — stale?"

### 6B. Memory Freshness

Parse `<!-- freshness: YYYY-MM-DD -->` headers from profile.md. For each active pack section, calculate age and classify as fresh/stale/expired per Memory Freshness Hierarchy (CLAUDE.md).

Count Agent Calibrations entries by freshness (using "Last updated" column).

```
  🧠  MEMORY FRESHNESS
  Core profile ........... ✅ fresh (Xd)
  Business ............... ✅ fresh (Xd) / ⚠️ stale (Xd) / ❌ expired (Xd)
  Life ................... ✅ / ⚠️ / ❌
  Health ................. ✅ / ⚠️ / ❌
  Learning ............... ✅ / ⚠️ / ❌
  Finance ................ ✅ / ⚠️ / ❌
  Agent calibrations ..... ✅ X/Y fresh / ⚠️ Z stale
```

- Only show sections for active packs
- If any section is ❌ expired → "Run /review-week to update stale data."
- If all fresh → "✅ All memory data is current."
- This check uses already-loaded profile.md — zero extra reads

### 7. Summary
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 bOS Health Check
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  👤 Profile ............ ✅ / ❌
  📁 State files ........ ✅ / ❌
  🔌 Superpowers ........ ✅ [X] active
  🤖 Agents ............. ✅ [X] active
  🌐 Cross-platform ..... ✅ / ❌ [X] missing
  🧠 Memory freshness ... ✅ / ⚠️ [X] stale / ❌ [X] expired
  📊 Mode ............... Lite / Pro

  Overall: ✅ Everything looks good!
  (or: ❌ [X] issues found — see above)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 8. Knowledge Level (how well bOS knows you)

Calculate completion by counting non-empty fields per section in profile.md:

```
  🧠  HOW WELL I KNOW YOU

  Core profile .............. ████████░░ 80%
  Work patterns ............. ██░░░░░░░░ 20%
  Financial picture ......... ██████░░░░ 60%
  Health & energy ........... ░░░░░░░░░░  0%
  Learning preferences ...... ████░░░░░░ 40%

  The more we talk, the better I get.
  [X] profile fields filled out of [Y].
```

Each bar = (filled fields in section / total fields in section) × 10 blocks.
If <50% overall → "Want to fill in some gaps? Each question takes 10 seconds."
Offer AskUserQuestion with the most impactful empty sections.

If issues found → offer to fix automatically:
"Want me to fix these issues? (yes/no)"
- Missing state files → create them
- Missing profile fields → ask quick questions to fill them
- MCP changes → update profile.md
