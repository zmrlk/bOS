<!-- Loaded by habit/SKILL.md — dashboard specs, quit-tracking schema, milestone tables, relapse protocol. -->

# /habit — tracker detail

## Streak overview (`/habit`)

Output intent: one compact line per habit — name, last 7 days as a simple done/missed strip, current streak, personal best; next milestone only when within 3 days of it. Visual and scannable (this is the dopamine view), but no fixed box template — render it clean in whatever fits the terminal. If a Quit Tracking section exists and is active, append one line per substance: day count free + amount saved.

## Milestone ladder (habits and quits)

3, 7, 14, 21, 30, 60, 90 days.

- Milestone hit → celebrate: short, warm, one concrete number ("14 days — two full weeks"), and name the next milestone.
- New streak > personal best → call out the record explicitly. Personal best is ALL-TIME and never resets.
- Normal completion → one-line log: habit, day number, brief encouragement.

## Owner-agent mapping (`/habit add`)

Only agents that exist in `.claude/agents/`: workout/exercise/training → @trainer · reading/books → @reader · food/meals/macros → @diet · finance/expense → @finance · anything else → @coach (default coordinator).

Row schema in habits.md: `| [name] | @[agent] | 0 | 0 | [today] | [frequency] |` (Streak, Best, Started, Frequency).

## Quit Tracking schema (`state/habits.md`)

Generic — any substance or behavior, the user names it:

```markdown
## Quit Tracking

| Substance | Quit date | Daily cost | Status |
|-----------|-----------|------------|--------|
| [name] | YYYY-MM-DD | [amount + currency] | active / planned |

### Milestones — [name]
| Milestone | When | Status |
|-----------|------|--------|
| 24h free | +1 day | ☐ |
| Craving peak survived | +3-6 days | ☐ |
| Sleep normalizing | +14 days | ☐ |
| Habit rewired | +66 days | ☐ |
```

### Nicotine health milestones (use verbatim for smoking — the only pre-approved health claims)

20 min heart rate normalizes · 8h CO halved · 48h taste/smell improving · 72h breathing easier · 2 weeks circulation improves · 1 month lung function +30% · 3 months circulation normal · 1 year heart disease risk halved.

For any other substance: ask the user or keep the generic four milestones above. **Never invent health claims.**

## Quit dashboard (`/habit quit`)

First run (no Quit Tracking section) → set it up: AskUserQuestion for what they're quitting, quit date (or "planned"), daily cost. Daily cost may come from `finances.md` if the spend is already logged. Create the section, then show the dashboard.

Dashboard content — days free (or "starts [date]" if planned), money saved (days × daily cost, with currency), last milestone achieved with its date, next milestone with days remaining, current streak vs best. Output intent: one screen, upbeat, numbers front and center — no fixed ASCII template.

Then: mark any newly achieved milestones, celebrate with one brief factual health note. Close with AskUserQuestion "How are you doing?" → Good / Craving / Hard / Skip. On "Craving" or "Hard": acknowledge, restate money saved and the next milestone, offer one coping step. No lecture.

## Relapse protocol

- NO JUDGMENT. Zero.
- Open with the gain: "One day doesn't erase the progress. The [X] days behind you still count."
- AskUserQuestion "Reset the counter?" → "Yes, start over" / "No, it was a slip — continuing" / "I need support".
- Streak uses DECAY: a slip costs −1 day, never a full reset (ADHD-friendly).
- Log to habits.md: `slip: [date], substance: [which], context: [if shared]`.

## Ambient mode

During other skills, quit status is max one line: day [X] free from [substance], saved [amount]. Full dashboard only on explicit `/habit quit`.

## Context-bus signals (max 2 per run)

| Condition | Signal |
|-----------|--------|
| Milestone hit (7, 14, 21, 30, 60, 90) | `@coach → @boss, Type: data, Priority: info, TTL: 3 days, Content: Habit milestone: [habit] — [X] days!` |
| Streak broken (was ≥ 7 days) | `@coach → @boss, Type: insight, Priority: normal, TTL: 7 days, Content: Streak broken: [habit] after [X] days. Check if systemic.` |
