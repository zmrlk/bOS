# bOS State File Schemas

> Authoritative format definitions for all state/*.md files.
> Skills and agents MUST follow these schemas when reading/writing.

## Growing File Structure (Smart Context Loading)

Growing state files (tasks.md, daily-log.md, finances.md, context-bus.md, weekly-log.md) use a 3-zone format:

```markdown
# [TITLE]

## Summary
<!-- AUTO-UPDATED -->
Active section: lines XX-YY
| Metric | Value |
| [key metrics] | [values] |

---

## Active
[current month + previous month data]

---

## Archive
[older data, moved here by maintenance]
```

**Small files** (habits.md, goals.md, decisions.md, projects.md, pipeline.md) do NOT use this format — they are read in full.

**Tier 1 (every session):** Read first 25 lines of growing files (= Summary only). Read small files in full.
**Tier 2 (on demand):** Skills read the Active section when they need details, using `offset` from Summary metadata.

**Migration:** When @boss detects a growing file without `## Summary` header → adds Summary + Active/Archive markers automatically.

---

## tasks.md

### Summary Template (first 25 lines)
```
# Tasks

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Today [YYYY-MM-DD] | X/Y done (Z%) |
| This week | X/Y done |
| Overdue | X tasks |
| Backlog | Y tasks |
| Avg completion 7d | Z% |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | When task was planned |
| Task | text | yes | Task description |
| Status | ☐/✅/⏭️ | yes | ☐ = todo, ✅ = done, ⏭️ = skipped |
| Energy | H/M/L | yes | Required energy: High/Medium/Low |
| Context | text | no | work / personal / health / learning |
| Time est. | Xmin/Xh | no | Estimated time |
| Agent | @name | no | Which agent created/owns this task |

### Format example:
```
## 2026-03-01

| Task | Status | Energy | Context | Time | Agent |
|------|--------|--------|---------|------|-------|
| Wypisz 3 potencjalnych klientów | ☐ | M | work | 30min | @sales |
| Spacer 20 min | ✅ | L | health | 20min | @trainer |
```

### Rules:
- One section per date (## YYYY-MM-DD)
- Tasks within date section as markdown table
- Carry-over: Copy ☐ tasks from yesterday to today's section
- Archive: Sections older than 2 months → state/archive/tasks-YYYY-MM.md

---

## daily-log.md

### Summary Template (first 25 lines)
```
# Daily Log

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Last entry | YYYY-MM-DD |
| Energy 7d avg | X.X |
| Energy trend | ↑/↓/→ |
| Sleep last 7d | X good, Y ok, Z bad |
| Exercise last 7d | X/7 days |
| Low battery days 14d | X |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | Log date |
| Energy AM | 1-10 | yes | Morning energy (from /morning) |
| Energy PM | 1-10 | no | Evening energy (from /evening) |
| Sleep | text | no | Sleep quality (good/ok/bad + hours) |
| Mood | text | no | Mood summary |
| Exercise | yes/no | no | Did user exercise? |
| Win | text | no | Day's biggest win |
| Notes | text | no | Free-form notes |

### Format example:
```
| Date | Energy AM | Energy PM | Sleep | Mood | Exercise | Win | Notes |
|------|-----------|-----------|-------|------|----------|-----|-------|
| 2026-03-01 | 7 | 5 | good, 7h | focused | yes | Closed deal | — |
| 2026-02-28 | 3 | 4 | bad, 5h | tired | no | Survived | Low Battery Day |
```

### Rules:
- Single table, newest entry on top
- /morning creates row with Energy AM only
- /evening UPDATES same row (adds Energy PM, Sleep, Mood, Win)
- If /evening runs without /morning entry → create full row
- Archive: Rows older than 2 months → state/archive/daily-log-YYYY-MM.md

---

## habits.md

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Habit | text | yes | Habit name |
| Owner | @agent | yes | Which agent tracks this |
| Streak | number | yes | Current consecutive days |
| Best | number | yes | Personal best streak (all-time high) |
| Last done | YYYY-MM-DD | yes | Last completion date |
| Target | text | no | Frequency goal (daily/3x week/etc.) |

### Format example:
```
| Habit | Owner | Streak | Best | Last done | Target |
|-------|-------|--------|------|-----------|--------|
| Morning workout | @trainer | 5 | 14 | 2026-03-01 | daily |
| Read 20 pages | @reader | 12 | 12 | 2026-03-01 | daily |
| Log expenses | @finance | 3 | 7 | 2026-02-28 | daily |
| Meal prep | @diet | 2 | 4 | 2026-02-27 | 2x week |
```

### Rules:
- Single table, sorted by streak (longest first)
- Streak resets to 0 if Last done > target interval
- @wellness is coordinator (primary writer), others POST updates via context-bus
- Archive: Keep active habits only. Abandoned habits (streak=0 for 30+ days) → archive note

---

## weekly-log.md

### Summary Template (first 25 lines)
```
# Weekly Log

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Last review | YYYY-MM-DD |
| Last completion rate | X% |
| 4-week avg | X% |
| Current week goal | [goal text] |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Week | YYYY-MM-DD | yes | Monday of the week |
| Week goal | text | yes | Primary focus for the week |
| Planned | number | yes | Tasks planned |
| Done | number | yes | Tasks completed |
| Rate | % | yes | Completion rate |
| Energy avg | number | no | Average energy for the week |
| Wins | text | no | Key wins |
| Lessons | text | no | What was learned |
| Next week | text | no | Carry-forward priorities |

### Format example:
```
## Week of 2026-02-24

| Field | Value |
|-------|-------|
| Week goal | Launch landing page |
| Planned | 12 |
| Done | 9 |
| Rate | 75% |
| Energy avg | 6.2 |
| Wins | Finished landing page design, got first lead |
| Lessons | Sprints work better than marathons |
| Next week | Follow up leads, start content calendar |
```

### Rules:
- One section per week (## Week of YYYY-MM-DD)
- /plan-week creates the section with week_goal and planned tasks
- /review-week fills in done, rate, wins, lessons, next week
- /standup can append notes mid-week
- Archive: Weeks older than 2 months → state/archive/weekly-log-YYYY-MM.md

---

## pipeline.md (Business pack only)

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Company/Client | text | yes | Lead name |
| Status | text | yes | cold / warm / hot / proposal / won / lost |
| Value | currency | no | Estimated deal value |
| Next step | text | yes | What to do next |
| Deadline | YYYY-MM-DD | no | Next step deadline |
| Last contact | YYYY-MM-DD | yes | Last interaction date |
| Notes | text | no | Context |

### Format example:
```
| Client | Status | Value | Next step | Deadline | Last contact | Notes |
|--------|--------|-------|-----------|----------|--------------|-------|
| Acme Corp | proposal | $5,000 | Send revised quote | 2026-03-05 | 2026-03-01 | Need CTO approval |
| StartupXYZ | warm | — | Schedule discovery call | 2026-03-03 | 2026-02-25 | Met at conference |
```

### Rules:
- Single table sorted by status priority (hot > warm > cold)
- @sales is primary writer
- Follow-up framework: Day 0 (initial), Day 3 (follow up), Day 7, Day 14
- Archive: Won/lost entries older than 1 month → state/archive/pipeline-YYYY-MM.md

---

## finances.md

### Summary Template (first 25 lines)
```
# Finances

## Summary
<!-- AUTO-UPDATED: buffer ALWAYS immediate, rest at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Buffer | XX% (X PLN / Y PLN target) |
| This month spent | X PLN |
| Budget remaining | X PLN |
| Top category | [category] |
| Impulse ratio | X% (X/Y expenses) |
| Last expense | YYYY-MM-DD, X PLN, [category] |

---
```

### Format:
```
## Budget — [Month YYYY]

| Category | Budgeted | Spent | Remaining |
|----------|----------|-------|-----------|
| Housing | 3,000 | 3,000 | 0 |
| Food | 1,500 | 800 | 700 |
| Transport | 500 | 200 | 300 |
| Subscriptions | 300 | 300 | 0 |
| Discretionary | 1,000 | 450 | 550 |

## Buffer

| Field | Value |
|-------|-------|
| Target | 3 months (X PLN) |
| Current | X PLN |
| Progress | XX% |
| Monthly savings | X PLN |

## Expense Log

| Date | Amount | Category | Description | Impulse? |
|------|--------|----------|-------------|----------|
| 2026-03-01 | 150 PLN | Food | Grocery shopping | no |
```

### Rules:
- One Budget section per month
- Buffer updated monthly by @finance
- Expense Log is append-only, newest on top
- @cfo owns business section (if separate), @finance owns personal
- Archive: Completed months → state/archive/finances-YYYY-MM.md

---

## goals.md

### Format:
```
## Active Goals

| Goal | Owner | Started | Target date | Progress | Status |
|------|-------|---------|-------------|----------|--------|
| Build 3-month buffer | @finance | 2026-01-15 | 2026-06-15 | 40% | on track |
| Run 5K | @trainer | 2026-02-01 | 2026-05-01 | 20% | on track |
| Learn Python basics | @teacher | 2026-03-01 | 2026-04-15 | 0% | new |

## Completed Goals

| Goal | Owner | Completed | Duration |
|------|-------|-----------|----------|
```

### Rules:
- @coach is coordinator (primary writer)
- Other agents POST goal updates to context-bus → @coach writes
- Progress updated weekly (during /review-week or /plan-week)
- Goals with no progress for 3+ months → flag for review
- Completed goals move to Completed section

---

## decisions.md

### Format:
```
## [YYYY-MM-DD] — [Decision title]

**Decision:** [What was decided]
**Options considered:** [List of alternatives]
**Reasoning:** [Why this option]
**Owner:** @[agent who made the recommendation]
**Status:** active / reversed / superseded
**Review date:** YYYY-MM-DD [When to revisit — required for GO/CONDITIONAL decisions]
```

### Rules:
- @ceo is primary writer
- Newest decision on top
- Major decisions also saved to agent memory (summary)
- Never delete decisions — mark as reversed/superseded with reason
- **Review date** is required for all GO and CONDITIONAL decisions. @ceo tracks pending reviews in memory: `pending_reviews: [{title, review_date}]`. /morning checks for reviews due today. /review-week shows upcoming reviews in next 7 days.

---

## projects.md (Business pack only)

### Format:
```
| Project | Client | Status | Hours est. | Hours actual | Deadline | Rate | Agent |
|---------|--------|--------|------------|--------------|----------|------|-------|
| Website redesign | Acme | active | 40h | 12h | 2026-04-01 | $100/h | @cto |
```

### Rules:
- @ceo, @coo, @cto are writers
- Hours updated weekly
- Completed projects move to archive

---

## context-bus.md

### Summary Template (first 25 lines)
```
# Context Bus

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
| Metric | Value |
|--------|-------|
| Pending critical | X |
| Pending normal | X |
| Pending info | X |
| Oldest pending | YYYY-MM-DD |

---
```

### Format:
```
## [YYYY-MM-DD] @source → @target(s)
Type: insight | decision | constraint | data | calibration
Priority: critical | normal | info
TTL: [expiry date, default: 14 days]
Content: [the finding]
Status: pending | acknowledged | acted-on | expired
```

### Signal types:
- `insight` — observation, pattern, correlation
- `decision` — decision made that affects other agents
- `constraint` — hard limit discovered (budget, time, health)
- `data` — raw data update (task done, expense logged, streak milestone)
- `calibration` — updated understanding of the user that other agents should know about

### Status lifecycle:
- `pending` → signal posted, not yet seen by target agent
- `acknowledged` → target agent has seen the signal
- `acted-on` → target agent has incorporated the signal into their behavior/response
- `expired` → past TTL, awaiting archival

### Rules:
- All agents can append (never edit others' entries)
- @boss sweeps on session start: surface critical+pending, mark expired
- @boss processes `calibration` signals: updates profile.md or reposts as targeted signals
- After acting on a signal, update Status to `acted-on`
- Monthly: archive expired and acted-on entries to state/archive/context-bus-YYYY-MM.md

---

## journal.md

Small file (read in full). Owner: @coach.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | Entry date |
| Q# | number | yes | Question ID from /reflect pool |
| Question | text | yes | The reflection question asked |
| Answer | text | yes | User's free-form response |

### Format example:
```
# Journal

| Date | Q# | Question | Answer |
|------|-----|----------|--------|
| 2026-03-02 | 14 | Co dziś poszło lepiej niż się spodziewałeś? | Udało mi się skończyć prezentację w godzinę |
| 2026-03-01 | 7 | Za co jesteś dziś wdzięczny? | Za dobrą rozmowę z Anią |
```

### Rules:
- Single table, newest entry on top
- @coach is primary writer (via /reflect skill)
- One entry per day (if user runs /reflect twice → update, don't duplicate)
- After 30+ entries → @coach triggers pattern analysis during /review-week
- Never delete entries — this is a personal journal

---

## invoices.md

Small file (read in full). Owner: @cfo.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Invoice # | INV-XXX | yes | Auto-increment invoice number |
| Date | YYYY-MM-DD | yes | Invoice creation date |
| Client | text | yes | Client/company name |
| Project | text | no | Related project |
| Amount | number | yes | Invoice amount |
| Currency | text | yes | Currency code (PLN, USD, EUR) |
| Status | text | yes | draft / sent / paid / overdue |
| Due date | YYYY-MM-DD | yes | Payment due date |
| Paid date | YYYY-MM-DD | no | Date payment received |

### Format example:
```
# Invoices

| Invoice # | Date | Client | Project | Amount | Currency | Status | Due date | Paid date |
|-----------|------|--------|---------|--------|----------|--------|----------|-----------|
| INV-001 | 2026-03-01 | Acme Corp | Website | 5000 | PLN | sent | 2026-03-15 | — |
| INV-002 | 2026-03-05 | StartupXYZ | Audit | 2000 | PLN | draft | 2026-03-19 | — |
```

### Rules:
- @cfo is primary writer (via /invoice skill)
- Invoice numbers auto-increment: find highest INV-XXX, increment by 1
- Status transitions: draft → sent → paid (or overdue if past due date)
- Never delete invoices — only update status
- Overdue = status != paid AND due date < today

---

## time-log.md

Growing file (Summary/Active/Archive format). Owner: @coo.

### Summary Template (first 25 lines)
```
# Time Log

## Summary
<!-- AUTO-UPDATED by @coo at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| This week total | Xh |
| Active timer | [project] since [time] / none |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Date | YYYY-MM-DD | yes | Entry date |
| Project | text | yes | Project name (from projects.md) |
| Duration | Xh Xm | yes | Time spent |
| Description | text | no | What was done |
| Agent | @name | no | Which agent/skill logged this |

### Format example:
```
## Active

| Date | Project | Duration | Description | Agent |
|------|---------|----------|-------------|-------|
| 2026-03-01 | Client Project | 2h 30m | Dashboard redesign | @devlead |
| 2026-03-01 | Side Project | 1h 15m | Landing page copy | @cmo |
```

### Rules:
- @coo is primary writer (via /timetrack skill)
- Active timer state stored in Summary section + @coo memory
- On /timetrack stop → calculate elapsed, append to Active section, update projects.md hours
- Archive: Entries older than 2 months → state/archive/time-log-YYYY-MM.md

---

## network.md

Small file (read in full). Owner: @mentor.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Name | text | yes | Person's name |
| Tier | inner/active/extended | yes | Relationship tier (inner 5, active 50, extended 500) |
| Context | text | yes | How you know them / relationship context |
| Last contact | YYYY-MM-DD | yes | Last meaningful interaction |
| Follow-up | YYYY-MM-DD | no | When to reach out next (auto-calculated from tier) |
| Notes | text | no | Conversation starters, shared interests, updates |

### Format example:
```
# Network

| Name | Tier | Context | Last contact | Follow-up | Notes |
|------|------|---------|-------------|-----------|-------|
| Ania K. | inner | Best friend, co-founder ideas | 2026-03-01 | 2026-03-15 | Interested in AI |
| Marek W. | active | Ex-colleague, design | 2026-02-10 | 2026-03-10 | Moved to Berlin |
| Jan N. | extended | Met at conference | 2026-01-05 | 2026-04-05 | Works at Google |
```

### Follow-up pipeline:
- **Inner (5):** Every 2 weeks
- **Active (50):** Every 1-2 months
- **Extended (500):** Every 3-6 months

### Rules:
- @mentor is primary writer (via /network skill)
- Sorted by follow-up date (most overdue first)
- Natural language input supported: "Spotkałem się z Anią" → parse + log
- /morning surfaces overdue inner-circle follow-ups as nudges

---

## inbox.md

Growing file (Summary/Active/Archive format). Owner: @boss.

### Summary Template (first 25 lines)
```
# Inbox

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Unread | X |
| Total active | X |
| Channels | telegram, email |
| Last message | YYYY-MM-DD HH:MM from [sender] via [channel] |

---
```

### Schema

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| ID | number | yes | Auto-increment message ID |
| Channel | text | yes | Source: telegram / email / slack / discord / whatsapp |
| Sender | text | yes | Sender name or ID |
| Subject/Preview | text | yes | Email subject or message preview (60 chars) |
| Status | text | yes | unread / read / routed / replied / archived |
| Routed to | @agent | no | Which agent handles this message |
| Date | YYYY-MM-DD HH:MM | yes | When message was received |

### Format example:
```
## Active

| ID | Channel | Sender | Subject/Preview | Status | Routed to | Date |
|----|---------|--------|-----------------|--------|-----------|------|
| 5 | telegram | Jan K. | Hej, masz chwilę na call? | unread | — | 2026-03-02 14:30 |
| 4 | email | newsletter@ai.com | Weekly AI digest | read | — | 2026-03-02 08:00 |
| 3 | slack | Anna M. | Czy masz aktualizację projektu? | routed | @coo | 2026-03-01 16:45 |
```

### Rules:
- Single table, newest message on top
- @boss is primary writer (via /inbox skill and session-start auto-check)
- Status transitions: unread → read → routed/replied/archived
- Archive: Messages older than 30 days AND status = replied/archived → state/archive/inbox-YYYY-MM.md
- In Pro mode, inbox.md is a fallback view — primary data in Supabase `messages` table

---

## schedules.md

Small file (read in full). Owner: @boss.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Name | text | yes | Schedule name (unique identifier) |
| Skill | text | yes | Skill command to execute (e.g., /morning) |
| Cron | text | yes | Cron expression (minute hour day month weekday) |
| Channel | text | yes | Delivery: in-app / telegram / email / slack |
| Active | yes/no/paused | yes | Current status |
| Last run | YYYY-MM-DD HH:MM | no | Last execution time |
| Next run | YYYY-MM-DD HH:MM | no | Calculated next execution |

### Format example:
```
# Schedules

| Name | Skill | Cron | Channel | Active | Last run | Next run |
|------|-------|------|---------|--------|----------|----------|
| morning | /morning | 0 8 * * * | telegram | yes | 2026-03-02 08:00 | 2026-03-03 08:00 |
| evening | /evening | 0 21 * * * | in-app | yes | 2026-03-01 21:00 | 2026-03-02 21:00 |
| standup | /standup | 0 9 * * 1 | in-app | paused | 2026-02-24 09:00 | — |
```

### Rules:
- @boss is primary writer (via /schedule skill)
- "In-app" schedules checked by @boss at session-start (overdue = run immediately)
- External delivery (telegram, email, slack) requires n8n workflows from templates/n8n/
- Paused schedules keep their config but don't execute

---

## marketplace.md

Small file (read in full). Owner: @boss.

| Column | Type | Required | Description |
|--------|------|----------|-------------|
| Skill ID | text | yes | Registry identifier |
| Command | text | yes | Skill command (e.g., /pomodoro) |
| Version | semver | yes | Installed version |
| Installed | YYYY-MM-DD | yes | Installation date |
| Source | text | yes | official / community |
| Last updated | YYYY-MM-DD | no | Last update date |

### Format example:
```
# Marketplace — Installed Skills

| Skill ID | Command | Version | Installed | Source | Last updated |
|----------|---------|---------|-----------|--------|--------------|
| pomodoro | /pomodoro | 1.0.0 | 2026-03-02 | official | 2026-03-02 |
```

### Rules:
- @boss is primary writer (via /marketplace skill)
- Only tracks MARKETPLACE-installed skills (not built-in bOS skills)
- Used by /evolve to check for updates
- Used by /marketplace update to compare versions

---

## telemetry.md

Small file (read in full). Owner: @boss. Auto-updated by session hooks and /review-week.

### Structure:

```markdown
# Agent Telemetry

<!-- Summary (auto-updated by @boss at session end) -->
Sessions: [N] | Since: [YYYY-MM-DD]
Top agents: [agent1], [agent2], [agent3]
Avg satisfaction: [X]/10
Routing accuracy: [X]%

## Agent Performance

| Agent | Invocations | Success | Neutral | Miss | Score |
|-------|------------|---------|---------|------|-------|
| @boss | 15 | 12 | 2 | 1 | 8.0 |

## Skill Performance

| Skill | Uses | Avg feedback | Avg tokens | Notes |
|-------|------|-------------|------------|-------|
| /morning | 10 | 9.0 | 1200 | stable |

## Routing Log

<!-- Recent routing decisions (last 20) -->
<!-- Format: date | input_summary | routed_to | correct? | notes -->
| 2026-03-03 | "plan my day" | @organizer | ✅ | |

## Misroute Patterns

<!-- Detected patterns from routing log analysis -->
<!-- Used by /evolve to propose disambiguation improvements -->

## Monthly Trends

<!-- Month | Sessions | Top agent | Satisfaction | Token cost -->
| 2026-03 | 15 | @boss | 8.5 | $2.40 |
```

### Columns — Agent Performance:

| Column | Type | Description |
|--------|------|-------------|
| Agent | text | Agent @mention |
| Invocations | integer | Total times invoked |
| Success | integer | Positive feedback or task completed |
| Neutral | integer | No feedback or OK |
| Miss | integer | Negative feedback or correction |
| Score | decimal | Weighted: (Success×10 + Neutral×5) / Invocations |

### Columns — Skill Performance:

| Column | Type | Description |
|--------|------|-------------|
| Skill | text | Skill command |
| Uses | integer | Total invocations |
| Avg feedback | decimal | Average satisfaction (1-10) |
| Avg tokens | integer | Average token cost per use |
| Notes | text | Trend or anomaly notes |

### Rules:
- Session count incremented by session-end.sh hook
- Agent/skill metrics updated by @boss at session end (lazy batch)
- Routing log: append-only, last 20 entries (older → archive)
- Misroute patterns: computed by /evolve Phase 2C
- Monthly trends: computed by /review-week on last Friday of month
- /review-week surfaces top insights from telemetry

---

## evolution-proposals.md

Small file (read in full). Owner: @boss (via /evolve skill).

### Structure:

```markdown
# Evolution Proposals

<!-- Generated by /evolve and reflexion analysis -->
<!-- Status: pending | approved | applied | rejected | rolled-back -->

## Pending Proposals

### [YYYY-MM-DD] Proposal: [title]
Agent: @agent | Type: prompt-patch | routing-rule | new-skill | config-change
Status: pending
Alignment: ✅ PURPOSE | ✅ BUDGET | ✅ CAPACITY | ✅ HEALTH | ✅ VALUES | ✅ SAFETY
Before: [current behavior]
After: [proposed behavior]
Evidence: [what triggered this — failure count, misroute pattern, etc.]
Backup: state/.backup/agents/[agent]-v[N].md (for prompt-patches)

## Applied

<!-- Proposals that were approved and implemented -->
### [date] Applied: [title]
[same fields + Applied date + Impact notes]

## Rejected

<!-- Proposals that were rejected by user, with reason -->
### [date] Rejected: [title]
Reason: [user's reason]

## Rolled Back

<!-- Patches that were applied but auto-reverted due to continued failures -->
### [date] Rolled Back: [title]
Reason: [continued negative feedback after N interactions]
Restored: [backup file path]
```

### Proposal Types:

| Type | Description | Backup required |
|------|-------------|-----------------|
| prompt-patch | Change to agent .md file | Yes (versioned) |
| routing-rule | New/changed disambiguation rule in CLAUDE.md | No |
| new-skill | Proposed skill creation | No |
| config-change | Settings, hooks, or infrastructure change | No |

### Alignment Check (Objective Kernel):
Every proposal must show all 6 gates: PURPOSE, BUDGET, CAPACITY, HEALTH, VALUES, SAFETY.
- ✅ = passes | ⚠️ = conditional (explain) | ❌ = blocks (do not present to user)

### Rules:
- Only /evolve writes to this file
- User must approve before any proposal is applied
- Prompt patches: auto-rollback after 2 continued failures post-apply
- Rejected proposals: track reason, do not re-propose same category twice
- Max 5 pending proposals at once (quality > quantity)
- Applied proposals: move from Pending to Applied with date and impact notes

---

## notes.md

Small file (read in full). Owner: @boss (via /note skill).

### Structure:

```markdown
# Notes

## Summary
| Total | Reminders | Ideas | Todos |
|-------|-----------|-------|-------|
| N     | N         | N     | N     |

## Active

### YYYY-MM-DD [icon] [content]
Type: reminder|idea|todo|note
Due: YYYY-MM-DD (reminders only)

---

## Archive
```

### Note Types:

| Type | Icon | Has Due date | Description |
|------|------|-------------|-------------|
| reminder | :calendar: | Yes | Time-bound reminder |
| idea | :bulb: | No | Captured idea |
| todo | :white_check_mark: | No | Quick action item |
| note | :pushpin: | No | General note (default) |

### Rules:
- @boss is sole writer (via /note skill)
- Zero questions on capture — `n [text]` = instant save
- Date parsing: "do 15 marca", "jutro", "w piątek" → extract to Due field
- Reminders surfaced by /morning (due today/tomorrow) and @boss session-start proactive checks
- Completed/deleted notes move to Archive section
- /home shows note count + nearest reminder
- /evening asks "Chcesz coś zanotować?" before close
- Don't duplicate — if very similar note exists, update instead of creating new
