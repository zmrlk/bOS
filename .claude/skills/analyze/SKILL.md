---
name: Data Analysis
description: "Professional data analysis — read CSV/JSON/Excel, summary statistics, outliers, ASCII charts, insights. Use when the user needs to analyze data files or validate pipeline data."
user_invocable: true
command: /analyze
---

# /analyze — Professional Data Analysis

Read, understand, and extract insights from data. Powered by @cto (technical execution) with @cfo/@sales for business context.

**Adapt to tech_comfort:** "I code" → show formulas, methodology. "I use apps" → focus on insights. "not technical" → plain language summaries.

---

## Subcommands

| Command | What it does | When to use |
|---------|-------------|------------|
| `/analyze [file]` | Read data file, summary statistics, outliers, ASCII charts | Any data file |
| `/analyze compare [file1] [file2]` | Cross-validate two data sources | Verify consistency |
| `/analyze report [file]` | Full report with insights and recommendations | Client deliverable |
| `/analyze pipeline` | Validate pipeline.md data quality | Pipeline health check |

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → tech_comfort, business context
- Data file(s) specified by user
- `state/pipeline.md` (if `/analyze pipeline`)

---

## /analyze [file] — Data Analysis

### Protocol:
1. Batch read: profile.md + data file
2. Parse data format:
   - CSV → native parsing (detect delimiter, headers)
   - JSON → native parsing (detect structure: array vs object)
   - Excel → detect file type, inform user if MCP needed
3. Produce analysis:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 DATA ANALYSIS — [filename]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  OVERVIEW
  ┌─────────────────────────────────┐
  │  Rows: [N]  Columns: [N]       │
  │  Data types: [list]            │
  │  Date range: [if applicable]   │
  └─────────────────────────────────┘

  SUMMARY STATISTICS
  ┌─────────────────────────────────┐
  │  [column]                       │
  │  Mean: [X]  Median: [X]        │
  │  Min: [X]   Max: [X]           │
  │  Std Dev: [X]                  │
  │  Missing: [N] ([%])            │
  └─────────────────────────────────┘

  DISTRIBUTION
  [column]:
  ████████████████  45%  [value A]
  ██████████        28%  [value B]
  ██████            17%  [value C]
  ███               10%  [value D]

  OUTLIERS
  → [N] outliers detected in [column]
  → [specific values if notable]

  TOP 3 INSIGHTS
  1. [actionable insight based on data]
  2. [actionable insight]
  3. [actionable insight]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. `AskUserQuestion`:
   - header: "Next"
   - options:
     - "Deep dive on [column]" (description: "More detail on specific column")
     - "Generate report" (description: "Full report for sharing")
     - "Done" (description: "Analysis complete")

---

## /analyze compare [file1] [file2] — Cross-Validation

1. Batch read both files
2. Identify common columns/keys
3. Compare:
   - Row count differences
   - Value mismatches on shared keys
   - Statistical divergence between matching columns
4. Report: match %, mismatches, recommendations

---

## /analyze report [file] — Full Report

1. Run full analysis (as above)
2. Add:
   - Executive summary (3 sentences)
   - Methodology note
   - Recommendations section (3-5 actionable items)
   - Limitations / data quality warnings
3. Format as shareable markdown document

---

## /analyze pipeline — Pipeline Validation

Specifically validates `state/pipeline.md` quality:

1. Batch read: profile.md, pipeline.md
2. Validation checks:
   - Missing required fields (company, status, next step, last contact)
   - Status consistency (lead "hot" + last contact >14 days = anomaly)
   - Stale leads (past follow-up deadline)
   - Value estimation gaps
   - Conversion rates by status
3. Report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊 PIPELINE HEALTH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Leads: [X] total, [Y] active
  Data quality: [X]% complete
  Stale leads: [N] (last contact >14d)

  By status:
  🟢 Hot: [N]    Value: [sum]
  🟡 Warm: [N]   Value: [sum]
  🔵 Cold: [N]   Value: [sum]

  Issues:
  ⚠️ [issue 1 with severity]
  ⚠️ [issue 2]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Context-Bus Signals

After analysis:
```
@cto → @ceo, Type: data, Priority: info, TTL: 7 days
Content: Data analysis completed for [file]. Key finding: [1-line insight].
Status: pending
```

---

## State Files
- **Read:** profile.md, data files, pipeline.md
- **Write:** None (read-only analysis)

---

## Rules

1. All file reads in 1 batch turn
2. Never fabricate data — only report what's in the file
3. ASCII charts for visual appeal (no external tools needed)
4. Top 3 insights must be ACTIONABLE, not just descriptive
5. Handle malformed data gracefully — report issues, continue with valid rows
6. Language matches user's language from profile.md
7. Max 2 context-bus signals per execution
