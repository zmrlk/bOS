---
name: Energy Map
description: "Personal energy science — visualize your energy patterns, find correlations, get actionable insights from your daily-log data."
user_invocable: true
command: /energy-map
---

# /energy-map — Personal Energy Science

Your energy is not random. Let's find the patterns.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → energy_pattern, work_style, adhd_indicators
- `state/daily-log.md` (Summary + full Active section, last 30 days) → energy, sleep, exercise data

### Step 2: Data sufficiency check

Count daily-log entries in last 30 days.
If < 30 entries:
```
  ⚡ Potrzebuję jeszcze [30 - X] dni danych.

  Loguj /morning i /evening codziennie.
  Za [30 - X] dni pokażę Ci pełną mapę energii.

  Mam już: [X] wpisów
  Potrzebuję: 30 wpisów minimum
```
→ End skill. Don't show partial analysis.

### Step 3: Day-of-week energy chart

Calculate average energy per day of week (Mon-Sun) from last 30 days.

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ⚡  MAPA ENERGII
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Pon  ████████░░  6.2
  Wto  ██████░░░░  4.8
  Śro  ███████░░░  5.5
  Czw  █████████░  7.1  ← PEAK
  Pią  ███████░░░  5.3
  Sob  ████████░░  6.0
  Ndz  ██████░░░░  4.5  ← LOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Correlations

Analyze available correlations (only show those with sufficient data):

**Exercise → Energy:**
- Days after exercise vs days without → average energy difference
- "Trening daje Ci +[X] do energii następnego dnia."

**Sleep → Energy:**
- Good sleep days vs bad sleep days → average energy difference
- "Dobry sen = +[X] energii. Zły sen = -[Y]."

**Weekend → Monday:**
- Saturday+Sunday activity level vs Monday energy
- "Po aktywnym weekendzie Twój poniedziałek jest o [X] lepszy."

**Sprint → Crash:**
- Count consecutive high-energy days before crash (energy drop ≥ 3 points)
- "Twój typowy sprint trwa [X] dni, potem crash. Planuj przerwy."

### Step 5: Insights (max 3)

```
  💡  INSIGHTS

  1. [Most actionable insight based on data]
  2. [Second insight]
  3. [Third insight — only if genuinely useful]
```

Rules for insights:
- Must be backed by data, not theory
- Must be actionable ("Train on Tuesday" not "Exercise is good")
- Hedging language for medium confidence (14-29 data points)
- Confident language for high confidence (30+ data points)

## Context-Bus Signals

No new signals — reads from daily-log.md + @boss memory patterns.

## State Files
- **Read:** profile.md, daily-log.md (S + full Active, 30 days)
- **Write:** none (read-only analysis)

## Rules
1. Minimum 30 entries required — don't show partial analysis
2. All reads in 1 turn (parallel I/O)
3. Max 3 insights — quality over quantity
4. Data-backed only — never theorize without numbers
5. Hedging language below 30 data points
6. No new state files — reads existing daily-log.md
7. Language matches user's profile language
