---
name: decide
description: "Structured decision-making — capture the decision, analyze options, get a GO/NO-GO verdict, and schedule a review. Use when the user faces a decision with trade-offs or uncertainty, or explicitly asks to decide."
user_invocable: true
command: /decide
tier: core
---

# /decide — Decision Journal

Make decisions with data, not anxiety. Every decision gets analyzed, recorded, and reviewed.

**Adapt to user_type:** Employee → career/life framing. Freelancer → business + life. Student → learning/career.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → user_type, primary_goal, active_packs
- `state/decisions.md` (full, small file) → past decisions for context
- `state/finances.md` (first 25 lines — Summary) → buffer status for financial decisions

### Step 2: Capture topic

If user specified in args (e.g., `/decide should I take this freelance project?`) → use that.
If no args → ask: "What decision are you facing?"

### Step 3: Decision type

Use `AskUserQuestion`:
- header: "Decision type"
- options:
  - "💼 Business" (description: "Project, client, investment, pivot")
  - "🌍 Life" (description: "Relocation, relationship, lifestyle change")
  - "💰 Financial" (description: "Purchase, expense, savings")
  - "🎓 Career" (description: "Job change, new skills, path")

### Step 4: Structured analysis

Gather information through conversation or structured questions:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋  ANALYSIS — [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ PROS:
  → [pro 1]
  → [pro 2]
  → [pro 3]

  ❌ CONS:
  → [con 1]
  → [con 2]
  → [con 3]

  🔄 Reversibility: [easy to undo / hard to undo / permanent]
  💰 Cost: [amount or "none" or "time only"]
  🎯 Goal alignment: [how this connects to primary_goal]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

For Business type → also score 5 dimensions (time-to-cash, rate, repeatability, reputation, feasibility — each 1-3, total /15). The scale drives the verdict thresholds below.
For Financial type → check buffer status, apply loss framing if relevant.

### Step 4b: Premortem (mandatory, 5 lines)

Assume the choice shipped and failed in 6 months. List: what broke, who got hurt, what warning you ignored. If you cannot name a failure mode, the analysis is incomplete.

### Step 5: Verdict

@boss delivers verdict:

```
  👔 @boss — VERDICT

  [GO / NO-GO / WAIT / CONDITIONAL]

  Reasoning: [2-3 sentences explaining why]

  Review date: [date — 30/60/90 days from now based on decision type]
```

Verdict rules:
- Business: Score ≤7 → NO-GO, 8-10 → CONDITIONAL, 11+ → GO
- Life/Career: Weight reversibility heavily — reversible = GO more easily
- Financial: Buffer < target → conservative bias
- WAIT: when timing is wrong but decision is right

### Step 6: Save

Write to `state/decisions.md`:
```
## [today] — [Decision title]

**Decision:** [verdict]
**Options considered:** [list]
**Reasoning:** [CEO reasoning]
**Owner:** @boss
**Status:** active
**Review date:** [date]
```

Update native auto-memory:
```
pending_reviews:
  - title: [decision title]
    review_date: [date]
```

### Step 7: Close

Use `AskUserQuestion`:
- header: "What next?"
- options:
  - "✅ Act on the decision" (description: "Close and move to action")
  - "🤔 I want to talk it over with the team" (description: "Structured Debate — more perspectives")
  - "📋 Show past decisions" (description: "List of decisions from decisions.md")

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Major decision (GO or CONDITIONAL) | `@boss → @boss + @coach, Type: decision, Priority: normal, TTL: 30 days, Content: Decision: [title] — [verdict]. Review: [date].` |

## State Files
- **Read:** profile.md, decisions.md (full), finances.md (S)
- **Write:** decisions.md

## Rules
1. Use AskUserQuestion for all choices
2. Max 2 context-bus signals per execution
3. All reads in 1 turn (parallel I/O)
4. Summary-only reads for growing files
5. Every GO/CONDITIONAL decision MUST have a review date
6. @boss tracks pending_reviews in memory
7. /morning checks for reviews due today
8. /evolve shows upcoming reviews in next 7 days
9. Never decide FOR the user — present analysis + recommendation, user decides
10. Language matches user's profile language
