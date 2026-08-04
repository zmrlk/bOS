---
name: Plan Week
description: "Weekly planning ritual. Create a focused plan for the upcoming week with energy-matched tasks. Best used Sunday evening."
user_invocable: true
command: /plan-week
---

# Weekly Planning

Read `profile.md` for active packs, energy patterns, available hours, work style, `user_type`, `tech_comfort`.

**Adapt to user_type:** Employee → work projects + career goals. Freelancer → client work + pipeline + invoicing. Student → study plan + assignments. Between things → goals + exploration steps.

## Protocol

### Step 1: Review last week (if data exists)
Check `state/weekly-log.md` or `state/tasks.md` for last week's results.
```
"📅 Quick look at last week:
✅ Completed: [X tasks]
⬜ Carried over: [Y tasks]
[1-line observation: pattern, win, or concern]"
```

### Step 2: Define the week
```
"What's the ONE thing that would make this week a success?"
```
Wait for answer. This becomes the week goal.

### Step 3: Build the plan

Generate a plan matching the user's `work_style` and `energy_pattern`:

```
📅 Week of [date]

🎯 WEEK GOAL: [user's answer]

MON: [task] — [energy: H/M/L] — Done when: [definition]
TUE: [task] — [energy: H/M/L] — Done when: [definition]
WED: [task] — [energy: H/M/L] — Done when: [definition]
THU: [task] — [energy: H/M/L] — Done when: [definition]
FRI: Weekly review (/review-week)
Weekend: [optional task OR rest]

✅ Success = [week goal achieved]
```

### Sprint Mode (if profile.md → sprint_mode = active)

If sprint mode is active, add capacity planning layer:

1. **Capacity:** Available hours from profile.md × 0.7 (buffer for surprises)
2. **SP conversion:** 1 SP ≈ 2h, 2 SP ≈ 4h, 3 SP ≈ 8h
3. **Per task:** Use `AskUserQuestion` to assign SP (1/2/3 or Skip)
4. **Commitment check:**
   - Total planned SP ≤ capacity → "✅ Sprint zaplanowany"
   - Total planned SP > capacity → "⚠️ Za dużo! Usuń [X] SP lub zmniejsz zadania"
5. **Save:** Update @coo memory → current_sprint with this week's data

Show capacity summary:
```
  🏃 SPRINT CAPACITY
  Available: [X]h × 0.7 = [Y] SP
  Planned: [Z] SP
  Velocity (4-week avg): [V] SP/week
```

### Rules:
- Max 1-2 tasks per day (not 5)
- Match H energy tasks to user's peak hours
- Tasks max 2 hours each
- Sprinters → smaller tasks, expect 1 crash day
- Scattered → ONE priority per day, never two
- Always include buffer day (nothing critical planned)
- Respect sacred rituals (from profile)

### Step 4: Implementation Intentions (If-Then)

After assigning each task, generate a specific implementation intention:

"MON: Write proposal for [client]
     Energy: HIGH | Done when: draft sent
     IF-THEN: When I sit down after my morning coffee,
              I will open a blank doc and write the first paragraph."

This pre-loads the decision, bypassing willpower. Particularly effective for ADHD.
Reference in /morning: "Remember your plan: when [trigger], you'll [action]."

### Context Bus Writes (after planning)

Post week plan signal to state/context-bus.md using canonical format:

```
## [date] @boss → all
Type: data
Priority: info
TTL: 7 days
Content: Week plan [date]: Goal = [week goal]. [X] tasks planned. Focus: [primary domain].
Status: pending
```

This lets all agents know the week's direction so they can align their advice.

### Step 5: Save
Update `state/tasks.md` with the week plan.

```
"Plan set. Tomorrow starts with [Monday task].
I'll brief you each morning (/morning). Let's go."
```
