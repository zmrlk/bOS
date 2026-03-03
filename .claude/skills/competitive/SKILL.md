---
name: Competitive Analysis
description: "Analyze competitors — pricing, positioning, strengths, weaknesses. Use when the user needs competitive intelligence or market analysis."
user_invocable: true
command: /competitive
model: sonnet
context: fork
---

# /competitive — Competitive Analysis

Deep-dive competitive intelligence. Powered by @ceo (with @cmo + @sales input).

**Adapt to tech_comfort:** "not technical" → plain language. "I use apps" → name tools. "I code" → detailed analysis.

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → industry, service, target audience, business description

---

## Protocol

### Step 1: Target Selection
If user names a competitor → proceed.
If not → ask:
`AskUserQuestion`:
- header: "Competitor"
- options:
  - "Name a competitor — I'll type it"
  - "Analyze my industry" (description: "Find key players in your space")

### Step 2: Research
Deep WebSearch:
- "[competitor name] website"
- "[competitor name] pricing"
- "[competitor name] reviews"
- "[competitor name] [user's industry]"

### Step 3: Structured Analysis

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 COMPETITIVE ANALYSIS — [Competitor]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  POSITIONING
  → [1 sentence: what they do, who they serve]

  PRICING
  → Model: [subscription / project / hourly / freemium]
  → Range: [price range if available]
  → Notes: [free trial, tiers, hidden costs]

  STRENGTHS
  → [strength 1 — specific, not generic]
  → [strength 2]
  → [strength 3]

  WEAKNESSES
  → [weakness 1 — from reviews, complaints]
  → [weakness 2]
  → [weakness 3]

  YOUR ADVANTAGE
  → [specific differentiator based on profile.md]
  → [how you can position against them]

  THREAT LEVEL: [Low / Medium / High]
  → [1-sentence justification]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Action Items
`AskUserQuestion`:
- header: "Next"
- options:
  - "Adjust my positioning" (description: "Update strategy based on findings")
  - "Analyze another competitor"
  - "Save to decisions" (description: "Log this analysis")
  - "Done"

If "Save to decisions" → write to state/decisions.md

---

## Context-Bus Signals

After analysis:
```
@ceo → @sales, Type: insight, Priority: info, TTL: 14 days
Content: Competitive analysis: [competitor]. Threat: [level]. Key differentiator: [1-line].
Status: pending
```

---

## State Files
- **Read:** profile.md (industry, service, target)
- **Write:** decisions.md (if user saves analysis as strategic decision)

---

## Rules

1. WebSearch for ALL competitor data — never fabricate
2. Strengths and weaknesses from REAL reviews and public data
3. "Your advantage" must be specific and based on profile.md data
4. All reads in 1 batch turn
5. Use AskUserQuestion for all choices
6. Add disclaimer: "Verify pricing data independently"
7. Language matches user's language from profile.md
8. Max 2 context-bus signals per execution
