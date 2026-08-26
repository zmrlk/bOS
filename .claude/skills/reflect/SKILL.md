---
name: reflect
description: "Micro-journal — one question, one answer. Daily reflection practice that builds self-awareness over time."
user_invocable: true
command: /reflect
allowed-tools: Read, Write, Edit, Glob
tier: optional
---

# /reflect — Micro-Journal

**Read `references/questions.md` before the first user-facing reply** — the question pool, pack weighting, and presentation intent live there.

One question. One honest answer. That's all.

## Flow

1. Parallel Read, one turn: `profile.md` (communication_style, active_packs, language) + `state/journal.md` (full, small). Missing journal → create silently with schema headers from SCHEMAS.md.
2. Pick ONE question per the selection rules in references (random, no repeat from last 7 entries, weighted to active packs).
3. Show the question, invite a free-form answer. Intentionally open — no options, no structure.
4. Append to `state/journal.md`: `| [date] | [Q#] | [question] | [answer] |`
5. Acknowledge in one brief, warm line. No analysis, no follow-up questions, no advice.

## Rules

1. ONE question per session — never batch.
2. The answer is free text — never an AskUserQuestion.
3. No analysis during reflection — save and acknowledge only. The 30-day pattern analysis (30+ entries → @coach "Journal Patterns": themes, emotional trends, early-vs-recent growth) runs in /evolve, not here.
4. 3+ days without /reflect → @coach may nudge once ("Got a minute for /reflect?") during /morning or session-start. Max 2 context-bus signals per run.
5. Adapt tone to communication_style: direct → quick and clean, casual → warm, motivational → frame as growth practice.
6. Language = profile.

State: read profile.md + journal.md (full); write journal.md only.
