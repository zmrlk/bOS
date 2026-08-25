---
name: reflect
description: "Micro-journal — one question, one answer. Daily reflection practice that builds self-awareness over time."
user_invocable: true
command: /reflect
allowed-tools: Read, Write, Edit, Glob
tier: optional
---

# /reflect — Micro-Journal

One question. One honest answer. That's all.

**Adapt to communication_style:** direct → quick and clean. casual → warm tone. motivational → frame as growth practice.

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → communication_style, active_packs, language
- `state/journal.md` (full, small file) → past entries, last 7 Q#s used

If journal.md doesn't exist → create with schema headers from SCHEMAS.md.

### Step 2: Pick question

Select a random question from the pool (~50 questions). Exclude any Q# used in the last 7 entries.

Weight toward the user's active packs:
- Life active → more self-awareness, gratitude, energy questions
- Business active → more growth, future, decision questions
- Health active → more energy, body, recovery questions
- Learning active → more growth, curiosity questions

### Step 3: Show question

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🪞  REFLECT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [Question text]

  (Write anything. No judgment.)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Wait for user's free-form text response. This is intentionally open — no selections, no structure.

### Step 4: Save

Append to `state/journal.md`:
```
| [today's date] | [Q#] | [question] | [user's answer] |
```

### Step 5: Acknowledge

Brief, warm acknowledgment:
"Saved. Thanks for taking a moment with yourself."

No analysis, no follow-up questions, no advice. Just acknowledgment.

### Step 6: 30-day analysis trigger

If journal.md has 30+ entries AND this runs during /evolve → @coach generates "Journal Patterns" section:
- Most common themes across answers
- Emotional trends (if detectable)
- Growth indicators (comparing early vs recent entries)

## Question Pool (~50, organized by category)

### Self-awareness (Q1-Q10)
1. What went better today than you expected?
2. What surprised you today?
3. If you could take back one decision from today — which one?
4. What annoyed you most today? Why?
5. Where were you the best version of yourself today?
6. What did you do today out of habit rather than choice?
7. What thought kept coming back to you all day?
8. What are you putting off that you know matters?
9. When did you feel most like yourself today?
10. What would you have told your morning self, knowing how the day turned out?

### Gratitude (Q11-Q20)
11. What are you grateful for today?
12. Who made your day better today?
13. What small moment from today do you appreciate?
14. What do you have now that you were dreaming about a year ago?
15. Which past failure are you grateful for now?
16. What in your life works well and doesn't need fixing?
17. Who haven't you appreciated in a while?
18. What ordinary part of your day would you miss if it disappeared?
19. What good is coming out of your current situation?
20. What do you appreciate about yourself?

### Growth (Q21-Q30)
21. What did you learn today?
22. What are you better at than you were a month ago?
23. What habit would you like to have a year from now?
24. What has been too much for you lately? What is it teaching you?
25. If you had a mentor — what would they tell you?
26. What skill would open the biggest doors for you?
27. What do you do well that you could do brilliantly?
28. What mistake do you keep repeating? What triggers it?
29. What would change if you took your own potential seriously?
30. What 1% improvement could you make tomorrow?

### Energy (Q31-Q40)
31. When did you have the most energy today? What gave it to you?
32. What tired you out most today?
33. Did you truly rest today, or just go through the motions?
34. What drains your energy that doesn't have to?
35. What would your ideal day look like, energy-wise?
36. What could you remove from your tomorrow?
37. When did you last feel flow?
38. What do you do for your health, and what just out of habit?
39. How much of today's energy went into things that actually matter?
40. What could give you +1 energy tomorrow?

### Future (Q41-Q45)
41. Where do you want to be in 90 days?
42. What happens if you change nothing?
43. What are you afraid to want?
44. What decision is waiting for you that you keep putting off?
45. If money didn't matter — what would you be doing?

### Relationships (Q46-Q50)
46. Who haven't you talked to in a while, but would like to?
47. Who helped you get to where you are?
48. Which relationship would you like to strengthen?
49. Who could you help this week?
50. Who is in your life because they chose to be?

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| 3+ days without /reflect | @coach proactive nudge: "Got a minute for /reflect?" (during /morning or session-start) |

## State Files
- **Read:** profile.md, journal.md (full)
- **Write:** journal.md

## Rules
1. ONE question per session — never batch questions
2. Free-form text response — no selections for the answer
3. No analysis during the reflection — just save and acknowledge
4. 30-day analysis happens in /evolve, not here
5. Max 2 context-bus signals per execution
6. All reads in 1 turn (parallel I/O)
7. Language matches user's profile language
