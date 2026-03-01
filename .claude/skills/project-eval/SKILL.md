---
name: Project Evaluation
description: "Evaluate a new project or opportunity with a structured Go/No-Go scoring framework. Use when considering a new client, project, or business opportunity."
user_invocable: true
command: /eval
---

# Project Evaluation

**Adapt to user_type:** Employee → evaluate career moves, internal projects, side gigs. Freelancer/Business → full client/project eval with pricing.

## Usage
User describes a project/opportunity. System runs multi-agent evaluation.

## Protocol

### Step 1: Gather info
If not already provided, ask:
```
"Tell me about this opportunity:
1. What's the project? (1-2 sentences)
2. Who's the client?
3. What's the budget/price?
4. What's the timeline?
5. How many hours do you estimate?"
```

### Step 2: Multi-agent evaluation (batch load + single response)

Load all relevant context in one batch of tool calls (finances, pipeline, projects, profile). Then generate all three agent opinions in a single response — no round-trips between agents.

**@sales** (if active): Client assessment
- Fit with ideal client profile
- Red flags
- Relationship potential

**@cfo** (if active): Financial analysis
- Effective hourly rate (price ÷ realistic hours)
- Payment terms recommendation
- Buffer impact

**@cto** (if active): Technical estimate
- Realistic hours (user's estimate × 2)
- Tech stack fit
- Complexity assessment

**Format:** Present all evaluations together in one block:
```
⏳ Czytam: finanse, pipeline, projekty...

🎯 @Sales — [assessment]
💰 @CFO — [assessment]
💻 @CTO — [assessment]
```

### Step 3: CEO Scoring (5 dimensions, 1-3 points each)

| Dimension | 1 pt | 2 pts | 3 pts |
|-----------|------|-------|-------|
| **Time to cash** | >30 days | 14-30 days | <14 days |
| **Effective rate** | Below minimum | At minimum | Above 1.5× minimum |
| **Repeatability** | One-off | Creates template | Builds product/retainer |
| **Reputation** | No effect | Case study material | Reference + referrals |
| **Feasibility** | Exceeds available hours | Fits in hours | Can do in half hours |

### Step 4: Verdict

```
"👔 @CEO — PROJECT EVALUATION

Score: [X]/15

[≤7]  ❌ PASS — Not worth your time right now.
[8-10] ⚠️ CONDITIONAL — Negotiate [specific suggestion].
[11+]  ✅ GO — Take it.

→ REASONING: [2-3 sentences]
→ RISK: [main risk]
→ NEXT STEP: [1 action]"
```

### Step 5: Log
Save to `state/decisions.md`:
```markdown
## [date] — [project name]
Score: [X]/15 — [GO/PASS/CONDITIONAL]
Reasoning: [summary]
```
