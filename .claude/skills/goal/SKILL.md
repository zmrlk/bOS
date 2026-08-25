---
name: goal
description: "Set, update, review, or complete goals. Works with @coach (life goals) and @boss (business goals)."
user_invocable: true
command: /goal
tier: core
---

# /goal — Goal Manager

## Usage
- `/goal` → show active goals
- `/goal set [description]` → set a new goal
- `/goal update [#] [progress note]` → update progress
- `/goal done [#]` → mark goal as completed
- `/goal review` → full goal review with progress

If user provides a goal without subcommand → treat as `/goal set`.

## Protocol

### Show goals (default — no args)
1. Read `state/goals.md`
2. If no active goals → "You don't have any goals yet. Want to set your first one?"
3. If goals exist → display active goals as compact list:
```
🎯 Your goals:

#1 [Goal] — [status] ([progress])
#2 [Goal] — [status] ([progress])
```
4. Quick Actions: "Update a goal" / "Add new" / "OK"

### Set goal
1. If description provided → use it. If not → ask: "What goal do you want to set?"
2. Auto-detect category from content:
   - Business/work/revenue/clients → business → owner: @boss
   - Health/fitness/weight/exercise → health → owner: @coach
   - Learning/skill/language/read → learning → owner: @reader
   - Life/habit/routine/relationship → life → owner: @coach
3. Use `AskUserQuestion` for target date:
   - header: "Deadline"
   - options: "1 week" / "1 month" / "3 months" / "6 months"
4. Add to `state/goals.md → Active Goals` table
5. If goal has clear sub-steps → auto-generate 2-3 milestones in Milestones table
6. Confirm: "Goal set. [Owner agent] will support you."

### Update goal
1. Read `state/goals.md`, find goal by #
2. Update Progress column with note
3. If progress suggests completion → ask: "Looks like this goal is achieved. Close it?"
4. Bus: `bash scripts/context-bus-append.sh "@coach" "ALL" "data" "info" "Goal #[X] updated — [progress]" 7`

### Complete goal
1. Move from Active Goals to Completed Goals with date and duration
2. Bus: `bash scripts/context-bus-append.sh "@coach" "ALL" "data" "normal" "Goal completed — [goal description]" 14`
3. Celebrate: "You said you'd do it. You did. That's huge."
4. Ask: "Want to set the next goal?" (AskUserQuestion)

### Review
1. Read all active goals with milestones
2. For each goal: calculate time elapsed vs target, show progress
3. Flag goals at risk (>50% time elapsed, <25% progress)
4. Suggest adjustments for struggling goals
5. End with: "One goal that deserves your focus this week: [most impactful]"

## ADHD Adaptation

Read `profile.md` → `adhd_indicators` before all goal operations.

**If adhd_indicators = yes/suspected:**

### Show goals
- Frame goals as challenges, not obligations: "🎯 Your challenges:" instead of "Your goals:"
- Show streak counters: "Streak: [X] days of active progress"
- Max 2 visible goals. If more exist: "You have [X] goals — these 2 matter most right now."

### Set goal
- Add dopamine hook: "New challenge accepted! 🔥 First milestone in [X] days."
- Auto-generate shorter milestones (1-2 weeks instead of months) for quicker wins
- Frame target dates as countdowns: "Challenge: [goal] in [X] days. Go!"

### Update goal
- Celebrate every update loudly: "📈 Progress! [progress bar ████░░░░ 40%]. Don't stop now!"
- If progress milestone hit → extra celebration: "🏆 MILESTONE! [description]. That's huge."

### Complete goal
- Maximum celebration: "🎉🎉🎉 CHALLENGE COMPLETE! [goal]. You said it, you did it. LEGEND."
- Show total streak/time: "From start to finish: [X] days. [Y] updates. Consistency = success."

### Review
- Show progress bars visually (████░░░░)
- Focus on wins first, risks second
- End with challenge framing: "Challenge of the week: [most impactful goal action]"

## State Files
- **Read:** state/goals.md, profile.md (primary_goal, adhd_indicators)
- **Write:** state/goals.md (Active Goals, Milestones, Completed Goals)

## Agents
- @coach owns life/health goals
- @boss owns business goals
- @reader/@coach own learning/career goals
