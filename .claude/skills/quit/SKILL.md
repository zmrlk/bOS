---
name: Quit
description: "Smoking cessation tracker with gamification. Track days smoke-free, money saved, health milestones, streaks. Use when user says 'quit', 'rzucam', 'ile dni', 'ile zaoszczędziłem', 'smoke free', or during daily check-ins after quit date."
user_invocable: true
command: /quit
---

# Quit Smoking Tracker

Gamified smoking cessation tracker. Two substances tracked: THC and nicotine (separate quit dates possible).

## Data Storage

In `state/habits.md`, maintain a Quit Tracking section:

```markdown
## Quit Tracking

| Substance | Quit date | Daily cost | Status |
|-----------|-----------|------------|--------|
| THC | 2026-03-28 | 86 PLN | active |
| Nicotine | TBD (tyg. 3) | 5 PLN | planned |

### Milestones — THC
| Milestone | When | Status |
|-----------|------|--------|
| 24h smoke-free | +1 day | ☐ |
| THC craving peak survived | +3-6 days | ☐ |
| Sleep normalizing | +14 days | ☐ |
| THC fully cleared from body | +30 days | ☐ |
| Habit rewired | +66 days | ☐ |

### Milestones — Nicotine
| Milestone | When | Status |
|-----------|------|--------|
| 20 min: heart rate normalizes | +20 min | ☐ |
| 8h: CO levels halved | +8 hours | ☐ |
| 48h: taste/smell improving | +2 days | ☐ |
| 72h: breathing easier | +3 days | ☐ |
| 2 weeks: circulation improves | +14 days | ☐ |
| 1 month: lung function +30% | +30 days | ☐ |
| 3 months: circulation fully normal | +90 days | ☐ |
| 1 year: heart disease risk halved | +365 days | ☐ |
```

## Protocol

### When user runs /quit (or ambient trigger)

**Step 1:** Read `state/habits.md` Quit Tracking section.

**Step 2:** Calculate and display dashboard:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚭 QUIT TRACKER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  THC:      [X] dni smoke-free 🔥
  Nikotyna: [Y] dni smoke-free 🔥
  (or "starts [date]" if planned)

  💰 ZAOSZCZĘDZONE:
  THC:      [X × 86] PLN
  Nikotyna: [Y × 5] PLN
  RAZEM:    [total] PLN

  🏥 OSTATNI MILESTONE:
  ✅ [milestone name] — [date achieved]

  ⏭️ NASTĘPNY MILESTONE:
  ☐ [next milestone] — za [Z] dni

  📊 STREAK: [longest] dni (rekord: [best])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Step 3:** Check for newly achieved milestones. If any:
```
🎉 NOWY MILESTONE!
[milestone name] — OSIĄGNIĘTY!
[brief health fact about this milestone]
```

**Step 4:** AskUserQuestion follow-up:
- "Jak się czujesz?" [Dobrze] [Craving] [Ciężko] [Skip]
- If "Craving" → show craving protocol from plan-rzucanie-palenia.md
- If "Ciężko" → acknowledge + remind money saved + next milestone

### Daily ambient check (during /morning or /evening)
If quit date has passed and status = active:
- Show 1-line status: "🚭 Dzień [X] bez [substance]. Zaoszczędzone: [amount] PLN"
- Check milestones silently, celebrate if new one achieved

### Relapse handling
If user says they smoked:
- NO JUDGMENT. Zero.
- "Jeden dzień nie niszczy postępu. [X] dni za Tobą wciąż się liczą."
- AskUserQuestion: "Reset counter?" [Tak, od nowa] [Nie, to był slip — kontynuuję] [Potrzebuję wsparcia]
- Streak uses DECAY: slip = -1 day, not full reset
- Log to habits.md: `slip: [date], substance: [which], context: [if shared]`

### Setup (first run)
If no Quit Tracking section in habits.md:
1. Read plan-rzucanie-palenia.md for quit dates
2. Create section with dates and milestones
3. Calculate daily cost from finances.md analysis (THC: ~86 PLN/day, Nicotine: ~5 PLN/day)

### Rules:
- Always positive framing (what they GAINED, not what they lost)
- Money saved = most powerful motivator (connect to buffer goal)
- Never say "you failed" — say "you slipped"
- Streak decay, not reset (ADHD-friendly)
- Max 3 lines in ambient mode, full dashboard only on /quit
