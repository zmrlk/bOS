---
name: Learning Path
description: "AI-powered learning roadmap — define what you want to learn, get a phased plan with resources, track progress through milestones."
user_invocable: true
command: /learn-path
---

# /learn-path — AI Learning Roadmap

Learn anything systematically. Goal → roadmap → milestones → mastery.

**Adapt to user_type:** Student → academic framing. Freelancer → skill monetization. Employee → career growth.

---

## Usage

- `/learn-path` — show active learning paths
- `/learn-path "topic"` — create new learning path
- `/learn-path progress` — update progress on active path

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → user_type, skills, primary_goal, language
- `state/goals.md` (Summary + Active) → existing learning goals
- `state/tasks.md` (Summary) → current workload context

### Subcommand: `/learn-path` (show active)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📚  LEARNING PATHS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. [Topic] — Phase [X]/3
     ██████░░░░  60%
     Next: [current milestone]

  2. [Topic] — Phase [X]/3
     ████░░░░░░  40%
     Next: [current milestone]

  No active paths? → /learn-path "topic"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Subcommand: `/learn-path "topic"` (create new)

#### Step 2: Topic capture

If specified in args → use that.
If no args → ask: "Czego chcesz się nauczyć?"

#### Step 3: Context gathering

Use `AskUserQuestion`:
- header: "Poziom"
- options:
  - "🟢 Początkujący" (description: "Zaczynam od zera")
  - "🟡 Średniozaawansowany" (description: "Mam podstawy, chcę więcej")
  - "🔴 Zaawansowany" (description: "Chcę się specjalizować / ekspert")

Use `AskUserQuestion`:
- header: "Cel nauki"
- options:
  - "💼 Kariera" (description: "Nowa praca, awans, zmiana branży")
  - "💰 Freelance" (description: "Nowa usługa, wyższe stawki")
  - "🧠 Osobisty rozwój" (description: "Dla siebie, z ciekawości")
  - "🎓 Certyfikat/Egzamin" (description: "Konkretny egzamin do zdania")

#### Step 4: Research

Use `WebSearch` to find:
- Current best learning paths for the topic (2026)
- Key prerequisites
- Recommended resources (free + paid)
- Typical timeline

#### Step 5: Generate roadmap

Create 3-phase roadmap:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🗺️  ROADMAP — [Topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  PHASE 1: Foundations (Week 1-[X])
  ├─ ☐ [Milestone 1]
  ├─ ☐ [Milestone 2]
  └─ ☐ [Milestone 3]
  Resources: [2-3 specific resources]

  PHASE 2: Application (Week [X]-[Y])
  ├─ ☐ [Milestone 4]
  ├─ ☐ [Milestone 5]
  └─ ☐ [Milestone 6]
  Resources: [2-3 specific resources]

  PHASE 3: Mastery (Week [Y]-[Z])
  ├─ ☐ [Milestone 7]
  ├─ ☐ [Milestone 8]
  └─ ☐ [Milestone 9]
  Resources: [2-3 specific resources]

  ⏱  Estimated: [X] weeks @ [Y] hrs/week
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### Step 6: Confirm and save

Use `AskUserQuestion`:
- header: "Plan OK?"
- options:
  - "✅ Zapisz i zacznij" (description: "Dodaj cele i pierwsze taski")
  - "✏️ Dostosuj" (description: "Chcę zmienić tempo lub zakres")
  - "❌ Anuluj" (description: "Nie teraz")

If confirmed:
1. Add learning goal to `goals.md`: "[Topic] — Phase 1 complete by [date]"
2. Add first 2-3 tasks to `tasks.md`: specific actions from Phase 1
3. Store in @teacher memory:
   ```
   learning_paths:
     - topic: [topic]
       level: [beginner/intermediate/advanced]
       current_phase: 1
       milestones: [{name, status, phase}]
       started: [date]
       next_review: [date + 2 weeks]
   ```
4. Store in @mentor memory: topic added for career/network context

### Subcommand: `/learn-path progress`

1. Show active paths with milestones
2. Use `AskUserQuestion` per milestone:
   - header: "[Milestone]"
   - options:
     - "✅ Done" (description: "Ukończone")
     - "🔄 In progress" (description: "Pracuję nad tym")
     - "⏭️ Skip" (description: "Pomijam")
3. Update @teacher memory
4. If phase complete → celebrate + unlock next phase tasks
5. Spaced repetition: @teacher schedules review of completed milestones

## Spaced Repetition

@teacher tracks completed milestones and schedules reviews:
- Day 1 after completion → quick recall prompt in /morning
- Day 7 → review prompt
- Day 30 → deep review
- Stored in @teacher memory: `spaced_reviews: [{topic, milestone, next_review, interval}]`

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Phase completed | `@teacher → @boss + @mentor, Type: data, Priority: info, TTL: 30 days, Content: Learning: [topic] Phase [X] complete. [Y]% overall.` |
| Path abandoned (30+ days no progress) | `@teacher → @coach, Type: insight, Priority: low, TTL: 14 days, Content: Learning path [topic] stalled. 30+ days no progress.` |

## State Files
- **Read:** profile.md, goals.md (S+Active), tasks.md (S)
- **Write:** goals.md, tasks.md

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. WebSearch for current resources — don't recommend outdated material
5. Max 9 milestones per path (3 per phase)
6. Milestones must be concrete and verifiable ("Build X" not "Understand Y")
7. @teacher owns spaced repetition schedule
8. @mentor connects learning to career/network opportunities
9. Phase unlocking: complete ≥2/3 milestones to advance
10. Language matches user's profile language
