---
name: wrap-up
description: "Structured session close with handoff notes for next session continuity. Eliminates re-discovery time. Use when user says wrap-up, zamykam, koniec sesji, or before significant breaks between sessions."
user_invocable: true
command: /wrap-up
tier: core
---

# /wrap-up — Session Handoff

Creates a structured handoff file so the next session starts exactly where this one left off. Eliminates the "re-explaining your project" problem.

## When to trigger
- User says "wrap-up", "zamykam", "koniec sesji", "na dziś koniec"
- Before context compaction (if session is getting long)
- End of significant work session (many file changes, decisions made)

## Protocol

### Step 1: Scan session context (silent, no user interaction)

Gather from current conversation:
1. **What was done** — list of completed actions, file changes, decisions made
2. **What's in progress** — started but not finished tasks
3. **What's blocked** — waiting on user input, external dependency, or decision
4. **Key decisions** — any architectural, strategic, or priority decisions made this session
5. **Context that would be lost** — things discussed but not written to state files (insights, user preferences expressed, mental models shared)

The handoff/digest is session history, not durable truth. Do not copy it into
`memory/`. Only facts the user explicitly asked to remember (or explicitly
confirmed during this session) may be saved via `/remember`.

### Step 2: Write handoff file

Write to `state/handoff.md` (overwrite previous — only latest matters):

```markdown
# Session Handoff
<!-- Generated: {datetime} -->
<!-- Session topic: {1-line summary} -->

## Goal
{what this session was for}

## Done
- {action}

## Blocked
- {item} — waiting on: {what}

## Next
{1 concrete action}

## Why
{why that next action — not just status}

## Source
{this session / file locator}

## Date
{ISO date}
```

### Step 3: Update state files (silent)

- Mark completed tasks in `tasks.md`
- Post critical signals via `bash scripts/context-bus-append.sh` (not hand-edit jsonl)
- Update `daily-log.md` if energy/wins were mentioned but not logged

### Step 4: Confirm to user

```
✅ Handoff saved. Next session starts from:
→ {suggested first action}
{1-line summary of what's in progress}
```

## Rules
- MAX 20 lines in handoff.md — concise, not comprehensive
- Focus on WHAT'S NOT IN STATE FILES — don't repeat tasks.md content
- Overwrite previous handoff — only latest matters
- If /evening runs in same session → /wrap-up adds handoff on top, doesn't replace /evening
- Language: match the user's language
