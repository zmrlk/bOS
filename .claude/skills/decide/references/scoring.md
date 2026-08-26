# /decide — scoring, verdicts, output structure

Detail for `/decide`. SKILL.md holds the protocol; this file holds the numbers and formats.

## Business scoring (5 dimensions, each 1-3, total /15)

Score every Business-type decision on all five before any verdict:

| Dimension | 1 | 3 |
|---|---|---|
| Time-to-cash | months away, uncertain | money lands fast |
| Rate | below the user's usual rate | clearly above it |
| Repeatability | one-off | leads to repeat work or a product |
| Reputation | invisible or risky for the brand | builds visible proof |
| Feasibility | new skills, unclear scope | known skills, clear scope |

2 = middle ground. Show the per-dimension scores and the total — the user should see how the verdict was earned.

**Thresholds (drive the verdict):**
- total ≤ 7 → NO-GO
- 8-10 → CONDITIONAL (name the condition that would flip it to GO)
- 11+ → GO

## Verdict rules by type

- **Business** → thresholds above.
- **Life / Career** → weight reversibility heavily: reversible decisions earn GO more easily; hard-to-undo or permanent ones need proportionally stronger pros.
- **Financial** → buffer below target → conservative bias; always state the cost against the buffer.
- **WAIT** → the decision is right but the timing is wrong; say what has to change before revisiting.

## Review scheduling

Every GO and CONDITIONAL decision gets a review date: 30, 60, or 90 days from today — pick the earliest date by which the outcome will actually be observable. Shorter horizons for financial and business calls, longer for structural life/career moves.

Tracking: add to auto-memory as

```
pending_reviews:
  - title: [decision title]
    review_date: [date]
```

`/morning` surfaces reviews due today; `/evolve` lists reviews due in the next 7 days.

## Output structure

Plain sections, short lines — no box art, no decorative separators.

**Analysis** (before the verdict):
- Pros (up to 3) and cons (up to 3)
- Reversibility: easy to undo / hard to undo / permanent
- Cost: amount, "time only", or "none"
- Goal alignment: how this connects to primary_goal
- Business type → the scoring table above; Financial type → buffer status and loss framing if relevant

**Premortem** (mandatory, ~5 lines): assume the choice shipped and failed in 6 months — what broke, who got hurt, which warning was ignored.

**Verdict** (rendered by @boss): GO / NO-GO / WAIT / CONDITIONAL, 2-3 sentences of reasoning, review date.

**Save** — append to `state/decisions.md`:

```
## [today] — [Decision title]

**Decision:** [verdict]
**Options considered:** [list]
**Reasoning:** [2-3 sentences]
**Owner:** @boss
**Status:** active
**Review date:** [date]
```

## Context-bus signal

Max 2 signals per execution. On GO or CONDITIONAL, helper only — never edit jsonl:

`bash scripts/context-bus-append.sh "@boss" "@coach" "decision" "normal" "Decision: [title] — [verdict]. Review: [date]." 30`
