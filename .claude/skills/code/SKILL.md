---
name: Code Pipeline
description: "Multi-phase code quality pipeline — plan, write, review, and secure code. Run /code build for full pipeline, /code review for review-only, /code secure for security check, /code ship for final quality gate."
user_invocable: true
command: /code
---

# /code — Code Quality Pipeline

Multi-phase code pipeline: plan → write → review → secure → deliver. Powered by @devlead.

**Adapt to tech_comfort:** "I code" → full technical detail, architecture decisions. "I use apps" → simplified, focus on what's being built. "not technical" → explain everything, no jargon.
**Adapt to ADHD:** If `adhd_indicators` = yes/suspected → auto-fix instead of reporting, max 3 action items, progress bars, dopamine hooks, no interruptions mid-pipeline.

---

## Subcommands

| Command | What it does | When to use |
|---------|-------------|------------|
| `/code` (no args) | Status of active coding session | Quick check |
| `/code build [description]` | Full pipeline: plan → write → review → secure → deliver | New feature/project |
| `/code review` | Review + security on existing code | Post-coding quality pass |
| `/code secure` | Security-only pass | Pre-deployment check |
| `/code ship` | Final quality gate + report + commit/PR | Ready to merge |

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch of tool calls:**
- `profile.md` (full) → tech_comfort, adhd_indicators, communication_style
- `state/projects.md` (full) → active projects, tech stack, hours
- Target project files via Glob/Grep (based on user's description)

---

## /code (no args) — Status

If @devlead has an active session in memory → show:
```
</> @DevLead — Active Session
Project: [name]
Phase: [current phase]
Quality: [last score/10]
```

If no active session → "No active coding session. Run `/code build [description]` to start."

---

## /code build [description] — Full Pipeline

### STEP 1: Context Loading
Batch read: profile.md, projects.md, target project files (Glob/Grep based on description).

### STEP 2: ARCHITECT Phase (voice of @cto)
Plan the architecture before writing code.

**Output:**
```
</> @DevLead — ARCHITECT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Architecture Decision:
→ [approach chosen]
→ Files: [list of files to create/modify]
→ Tech stack: [languages/frameworks]
→ API contracts: [if applicable]

Checklist:
✅ Separation of concerns
✅ Project conventions followed
✅ Dependencies justified
✅ Data model defined
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then `AskUserQuestion`:
- header: "Plan"
- options:
  - "Build it" (description: "Proceed with this architecture")
  - "Change approach" (description: "I want to modify something")
  - "More details" (description: "Explain the reasoning")

### STEP 3: WRITER Phase (voice of "Dev")
Write clean, working code.

**During writing, show progress:**
```
⏳ Writing [filename]...
✅ [filename] — done
⏳ Writing [filename]...
✅ [filename] — done
```

**Writer Checklist:**
- [ ] Compiles / no syntax errors
- [ ] Follows project style conventions
- [ ] Error handling for edge cases
- [ ] Type safety (if TypeScript)

### STEP 4: REVIEWER Phase (voice of "Reviewer")
Senior dev PR review with severity ratings.

**Output format:**
```
</> @DevLead — REVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[file:line] 🔴 BLOCK: [issue]
  Fix: [specific fix applied or required]

[file:line] ⚠️ SUGGEST: [issue]
  Suggestion: [what to change]

[file:line] 💬 NITPICK: [issue]
  Consider: [optional improvement]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Reviewer Checklist:**
- [ ] Logic correctness
- [ ] Edge cases handled
- [ ] DRY — no unnecessary repetition
- [ ] Naming is clear and consistent
- [ ] Tests cover critical paths (if applicable)

**ADHD rule:** Show max 3 items. Auto-fix 🔴 BLOCK items. If more than 3 issues → fix the top 3, note remaining count: "Fixed 3 critical issues. 2 minor suggestions saved for later."

### STEP 5: GUARDIAN Phase (voice of "Guardian")
Security + performance specialist — last gate.

**SECURITY checklist (adapted to TS/React/Supabase):**
- [ ] No hardcoded secrets/API keys
- [ ] Input validation on all user inputs
- [ ] SQL injection protected / Supabase RLS configured
- [ ] XSS prevention (no dangerouslySetInnerHTML without sanitization)
- [ ] Auth on protected routes
- [ ] CORS configured
- [ ] No sensitive data in client bundle

**PERFORMANCE checklist:**
- [ ] No O(n²) without justification
- [ ] No N+1 queries
- [ ] Bundle size impact acceptable
- [ ] Memo/useMemo where needed
- [ ] Lazy loading for heavy components

**Output:**
```
</> @DevLead — GUARDIAN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SECURITY: [✅ PASS / ⚠️ WARNING / 🔴 FAIL]
[issues if any]

PERFORMANCE: [✅ PASS / ⚠️ WARNING / 🔴 FAIL]
[issues if any]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### STEP 6: DELIVERY REPORT

**Quality Card:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  </> CODE QUALITY REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Architecture .... ✅ / ⚠️ / 🔴
  Code ............ ✅ / ⚠️ / 🔴
  Review .......... ✅ / ⚠️ / 🔴
  Security ........ ✅ / ⚠️ / 🔴
  Performance ..... ✅ / ⚠️ / 🔴

  Overall: [score]/10 — [PASS/CONDITIONAL/BLOCK]

  [If auto-fixes applied:]
  Auto-fixed: [N] issues
  Remaining: [N] suggestions (non-blocking)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then `AskUserQuestion`:
- header: "Ship?"
- options:
  - "Ship it" (description: "Create commit/PR") — only if PASS or CONDITIONAL
  - "More details" (description: "Show full review")
  - "More changes" (description: "I want to modify before shipping")

---

## /code review — Review Only

Skip ARCHITECT and WRITER phases. Run REVIEWER + GUARDIAN on existing code.
1. Ask user what to review (file, directory, or "recent changes")
2. Glob/Grep/Read the target files
3. Run REVIEWER phase (Step 4)
4. Run GUARDIAN phase (Step 5)
5. Show DELIVERY REPORT (Step 6)

---

## /code secure — Security Only

Run GUARDIAN phase only.
1. Ask user what to check (file, directory, project)
2. Glob/Grep/Read the target files
3. Run GUARDIAN phase (Step 5) — security checklist only
4. Show security report

---

## /code ship — Final Quality Gate

Pre-merge checklist + commit/PR creation.
1. Run quick REVIEWER + GUARDIAN pass
2. Show final DELIVERY REPORT
3. If PASS or CONDITIONAL:
   - If GitHub MCP available → offer to create PR via `gh pr create`
   - If not → offer to create git commit
4. `AskUserQuestion`:
   - "Create PR" (if GitHub MCP)
   - "Create commit"
   - "Not yet"

---

## Context-Bus Signals

After pipeline completion:
```
@devlead → @cto, Type: data, Priority: info, TTL: 7 days
Content: Code pipeline [PASS/FAIL] for [project]. Score: [X]/10.
Status: pending
```

If critical security issue found:
```
@devlead → @ceo, Type: insight, Priority: critical, TTL: 14 days
Content: Security vulnerability in [project]: [brief description].
Status: pending
```

---

## Integrations

- `/sprint` → code tasks tracked as story points
- `/focus` → after focus session: suggest "/code review?"
- `projects.md` → hours logged after pipeline
- GitHub MCP → `/code ship` creates PR

---

## State Files
- **Read:** profile.md, projects.md
- **Write:** projects.md (review notes, quality scores)

---

## Rules

1. Never skip GUARDIAN phase — security is non-negotiable
2. Auto-fix 🔴 BLOCK items when possible — reduce decision fatigue
3. Max 3 action items per step (ADHD-friendly)
4. Questions only at pipeline start (Step 2) and end (Step 6) — no mid-pipeline interruptions
5. Progress bars for every step (⏳ → ✅)
6. Always show the Quality Card at the end
7. Language matches user's language from profile.md
8. All file reads in 1 batch turn (parallel I/O rule)
