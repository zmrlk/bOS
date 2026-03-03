---
name: Proposal Generator
description: "AI-powered proposal generator for client projects. Personalized opening, scope, timeline, pricing, portfolio reference. Use when the user needs to create a proposal or offer for a client."
user_invocable: true
command: /proposal
model: sonnet
---

# /proposal — AI Proposal Generator

Generate professional, personalized proposals for client projects. Powered by @sales (copy) + @cfo (pricing).

**Validated insight:** Freelancers spend 30% of time on proposals. AI+human hybrid yields 27% response rate (vs ~10% manual).

**Adapt to tech_comfort:** Adapt proposal language to match user's professional level.
**Adapt to communication_style:** Match user's voice in the proposal.

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → service, rate, portfolio, brand_voice, minimum_hourly_rate
- `state/pipeline.md` (full) → client context
- `state/projects.md` (full) → past work, references

---

## Protocol

### Step 1: Client Selection
`AskUserQuestion`:
- header: "Client"
- options: [list leads from pipeline.md with status warm/hot + "New client"]

If "New client" → ask for company name, contact person.

### Step 2: Project Type
`AskUserQuestion`:
- header: "Project type"
- options (from profile.md service categories):
  - "[Service 1]"
  - "[Service 2]"
  - "[Service 3]"
  - "Custom — I'll describe it"

### Step 3: Client Research (if new or limited data)
If client not in pipeline or limited context:
- WebSearch: "[company name] [industry]" for background
- Fill context: company size, industry, recent news

### Step 4: Generate Proposal Draft

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📋 PROPOSAL — [Client Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  OPENING
  [Personalized 2-3 sentences referencing client's
   situation, industry, or recent news. Not generic.]

  SCOPE OF WORK
  → [Deliverable 1]
  → [Deliverable 2]
  → [Deliverable 3]

  TIMELINE & MILESTONES
  Week 1: [milestone]
  Week 2: [milestone]
  Week 3: [milestone]
  Delivery: [date]

  INVESTMENT
  ┌─────────────────────────────────┐
  │ [Scope item]     │ [price]     │
  │ [Scope item]     │ [price]     │
  │──────────────────│─────────────│
  │ Total            │ [total]     │
  └─────────────────────────────────┘
  Payment terms: [from profile or default 50/50]

  WHY ME
  → [Relevant past project with result]
  → [Specific expertise match]
  → [Social proof if available]

  NEXT STEPS
  → Reply to this proposal to confirm
  → Discovery call: [suggest date/time]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: User Review
`AskUserQuestion`:
- header: "Proposal"
- options:
  - "Send" (description: "Copy text and mark in pipeline")
  - "Edit" (description: "I want to change something")
  - "Save draft" (description: "Save for later")

### Step 6: Pipeline Update
If "Send" selected and lead exists in pipeline.md:
- Update pipeline.md status to "proposal"
- Update last contact date to today

---

## Context-Bus Signals

After proposal sent:
```
@sales → @ceo, Type: data, Priority: info, TTL: 14 days
Content: Proposal sent to [client] for [project type]. Value: [amount].
Status: pending
```

---

## State Files
- **Read:** profile.md, pipeline.md, projects.md
- **Write:** pipeline.md (status update after sending)

---

## Rules

1. Opening MUST be personalized — never generic "Dear Sir/Madam"
2. Use WebSearch for client research when context is limited
3. Pricing from @cfo logic: rate × hours × estimate_multiplier
4. Past project references must be REAL (from projects.md)
5. All reads in 1 batch turn
6. Use AskUserQuestion for all choices
7. Proposal text is copy-paste ready
8. Language matches user's language from profile.md
9. Max 2 context-bus signals per execution
