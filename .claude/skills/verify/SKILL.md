---
name: Pipeline Verification
description: "Verify and enrich pipeline data. Check for missing fields, stale leads, duplicates, and enrich with web research. Use when the user needs to clean up their sales pipeline."
user_invocable: true
command: /verify
context: fork
---

# /verify — Pipeline Data Verification

Verify, clean, and enrich your sales pipeline data. Powered by @sales.

**Adapt to tech_comfort:** "not technical" → simple language. "I use apps" → name tools. "I code" → show data details.

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → business context
- `state/pipeline.md` (full) → all leads

---

## Protocol

### Step 1: Load and Validate
1. Batch read: profile.md, pipeline.md
2. Run validation checks:

**Data Quality Checks:**
- Missing required fields (company, status, next step, last contact)
- Status consistency: lead "hot" + last contact >14 days = anomaly
- Duplicate detection: similar company names (fuzzy match)
- Stale leads: past follow-up deadline without update
- Value estimation gaps: hot/warm leads with no value estimate

### Step 2: Enrichment (WebSearch)
For leads with missing data:
- WebSearch: "[company name] [industry/location]" for company info
- Look for: company size, industry, recent news, LinkedIn page

### Step 3: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔍 PIPELINE HEALTH REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  OVERVIEW
  Leads: [X] total, [Y] active
  Data quality: [X]% complete
  Total value: [sum]

  ISSUES FOUND
  🔴 [N] Critical:
  → [issue — e.g., "3 hot leads with no contact in 14+ days"]

  ⚠️ [N] Warnings:
  → [issue — e.g., "2 leads missing value estimate"]

  💬 [N] Info:
  → [issue — e.g., "1 potential duplicate: Acme / Acme Corp"]

  ENRICHMENT RESULTS
  → [Company X]: [new info found via WebSearch]
  → [Company Y]: [new info found]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Fix Offer
`AskUserQuestion`:
- header: "Actions"
- options:
  - "Fix all issues" (description: "Auto-fix what we can, ask about the rest")
  - "Show details" (description: "See each issue individually")
  - "Skip" (description: "No changes")

If "Fix all":
- Update pipeline.md: add enriched data, fix status inconsistencies
- Flag items that need user input: "These need your decision: [list]"

---

## Context-Bus Signals

After verification:
```
@sales → @ceo, Type: data, Priority: info, TTL: 7 days
Content: Pipeline health: [X]% complete. [N] issues found, [M] fixed.
Status: pending
```

---

## State Files
- **Read:** profile.md, pipeline.md
- **Write:** pipeline.md (enriched data, fixed inconsistencies)

---

## Rules

1. WebSearch for enrichment — don't ask user for info you can find
2. All reads in 1 batch turn
3. Use AskUserQuestion for all choices
4. Show severity levels for issues (critical/warning/info)
5. Auto-fix what's possible, ask only for decisions
6. Never delete pipeline entries — only update/enrich
7. Language matches user's language from profile.md
8. Max 2 context-bus signals per execution
