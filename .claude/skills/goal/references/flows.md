<!-- Loaded by goal/SKILL.md — reference detail, not a skill. -->

# /goal — flows

## Show (default, no args)

1. Read `state/goals.md`.
2. No active goals → "You don't have any goals yet. Want to set your first one?"
3. Otherwise a compact list:

```
🎯 Your goals:

#1 [Goal] — [status] ([progress])
#2 [Goal] — [status] ([progress])
```

4. Quick actions (AskUserQuestion): "Update a goal" / "Add new" / "OK".

## Set

1. Description provided → use it. Missing → ask "What goal do you want to set?" (the one allowed open-text question).
2. Auto-detect category → owner (mapping in SKILL.md).
3. AskUserQuestion — header: "Deadline", options: "1 week" / "1 month" / "3 months" / "6 months".
4. Add to `state/goals.md → Active Goals`.
5. If the goal has clear sub-steps → auto-generate 2–3 milestones in the Milestones table.
6. Confirm: "Goal set. [Owner agent] will support you."

## Update

1. Find the goal by # in `state/goals.md`; update the Progress column with the note.
2. Progress suggests completion → ask: "Looks like this goal is achieved. Close it?"
3. Bus: `bash scripts/context-bus-append.sh "@coach" "ALL" "data" "info" "Goal #[X] updated — [progress]" 7`

## Done

1. Move from Active Goals to Completed Goals with date and duration.
2. Bus: `bash scripts/context-bus-append.sh "@coach" "ALL" "data" "normal" "Goal completed — [goal description]" 14`
3. Acknowledge the completion in your own words — name what they did and how long it took.
4. AskUserQuestion: "Want to set the next goal?"

## Review

1. Read all active goals with milestones.
2. Per goal: time elapsed vs target, current progress.
3. Flag at-risk goals: >50% time elapsed, <25% progress.
4. Suggest adjustments for struggling goals.
5. End with: "One goal that deserves your focus this week: [most impactful]."

## ADHD display variants (adhd_indicators = yes/suspected)

- **Show:** header "🎯 Your challenges:" instead of "Your goals:"; streak counter ("Streak: [X] days of active progress"); max 2 goals — if more exist: "You have [X] goals — these 2 matter most right now."
- **Set:** auto-generate shorter milestones (1–2 weeks instead of months) for quicker wins; frame the target date as a countdown: "Challenge: [goal] in [X] days."
- **Update:** show a progress bar with every update (████░░░░ 40%); when a milestone is hit, name it explicitly.
- **Done:** show total time and update count: "From start to finish: [X] days. [Y] updates."
- **Review:** progress bars for every goal; wins first, risks second; end with challenge framing: "Challenge of the week: [most impactful goal action]."
