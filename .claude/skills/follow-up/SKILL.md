---
name: Follow Up
description: "Automated follow-up scripts for your leads. When to follow up, what to say, how not to be pushy. Use when the user needs to follow up with a potential client or cold contact."
user_invocable: true
command: /follow-up
tier: optional
---

# /follow-up — Lead Follow-up Generator

Sales die in the follow-up. 80% of deals close after 5+ touches — most people give up after 1.
This skill tells you: when to write, what to write, how not to be pushy.

**Agent:** @cmo (scripts) + @boss (timing + reminder)

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (sections: Business, offer, brand_voice)
- `state/pipeline.md` (full) → list of current leads and their statuses

---

## Protocol

### Step 1: Context

AskUserQuestion:
- header: "Situation"
- question: "What happened?"
- options:
  - "I sent a cold outreach, no reply" (description: "Follow-up after 3-5 days of silence")
  - "We had a meeting / call, waiting for a decision" (description: "Follow-up after a demo or first conversation")
  - "I sent an offer/follow-up, no reply" (description: "Follow-up after sending a quote")
  - "The client said 'not now'" (description: "Closed lead — when and how to come back")

---

### Scenario A: After cold outreach (no reply)

**Timing:**
- Follow-up 1: +4-5 days after first contact
- Follow-up 2: +7 days after F1 (different channel — e.g. LinkedIn → email)
- Follow-up 3: +14 days after F2 (break-up message — the last one)

**Generate 3 ready-to-send messages:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 1 — +5 days
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[READY TEXT — max 3 sentences]
Channel: [LinkedIn / email]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 2 — +7 days
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[READY TEXT — new value or a question]
Channel: [different from F1]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📨  Follow-up 3 — Break-up message
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[READY TEXT — give them an out, but leave the door open]
Channel: any

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⏰  Reminders:
  Tomorrow: send F1
  [date]: send F2
  [date]: send F3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Scenario B: After a meeting (waiting for a decision)

**Timing:**
- Follow-up: 24-48h after the meeting (while it's fresh)
- Second: +5-7 days if no reply
- Third: +10-14 days (decision urgency — soft deadline)

**Post-meeting message structure:**
1. Thank-you (1 sentence) — specific, what was valuable
2. Summary of key points (2-3 bullets max)
3. Clear next step + question (1 sentence)

If [user] shares what the meeting covered → personalize.

---

### Scenario C: After sending an offer

**Timing:**
- Follow-up: +3 days ("Wanted to make sure it reached you")
- Second: +7 days ("Any questions about the offer?")
- Third: +14 days ("We're planning our schedule — I'd like to know if this makes sense")

**Rule:** A follow-up after an offer does NOT ask for a decision — it asks for questions and doubts.

---

### Scenario D: "Not now" — when to come back

**Comeback map:**

| What they said | When to return | How to return |
|--------------|-------------|-----------|
| "We're in the middle of a renovation/rollout" | +6-8 weeks | "I remember you had [X] going on — how did it go?" |
| "No budget this quarter" | Start of the new quarter | Trigger: Q2 (April), Q3 (July) |
| "I need to think it over" | +2 weeks | New information / case study |
| "No, thank you" | +3-6 months if worth it | Only if something material has changed |

Generate: a specific reminder date + a ready-to-send comeback message.

---

## Follow-up rules

**DO:**
- Always add new value in every follow-up (not just "have you thought it over?")
- Keep it short — max 5 sentences. Longer = spam.
- Make it personal — one specific sentence about their company/situation
- Closed question at the end (yes/no/when) — not open-ended
- The break-up message always leaves the door open ("If anything changes...")

**Anti-fit:** If the lead is not ready (no budget, no owner, wrong problem), do **not** sell the expensive path. Say no or offer a cheaper/no-go. A bad-fit close is a failure.

**DON'T:**
- "Just checking in" — the worst sentence in a follow-up
- "Have you made a decision?" — pressure, scares them off
- Same-day follow-up — desperation signal
- More than 3 follow-ups without a reply — end the series

---

## Pipeline integration

If `state/pipeline.md` exists and has leads with status "contacted" or "proposal-sent":
- Automatically identify which leads need a follow-up (based on last contact date)
- Propose: "Lead [X] has had no contact for [N] days. Generate a follow-up?"

---

## Response format

Always:
1. Ready-to-copy text (in a block)
2. Timing (when to send)
3. Channel (where to send)
4. One tip on why this structure works

⏭️ Next step: Copy and send F1 today.
