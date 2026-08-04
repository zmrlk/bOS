---
name: Wrap Up
description: "Structured session close with handoff notes for next session continuity. Eliminates re-discovery time. Use when user says wrap-up, zamykam, koniec sesji, or before significant breaks between sessions."
user_invocable: true
command: /wrap-up
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

### Step 2: Write handoff file

Write to `state/handoff.md` (overwrite previous — only latest matters):

```markdown
# Session Handoff
<!-- Generated: {datetime} -->
<!-- Session topic: {1-line summary} -->

## Done this session
- {action 1}
- {action 2}

## In progress
- {task} — status: {where it stands}, next: {what to do next}

## Blocked
- {item} — waiting on: {what}

## Decisions made
- {decision}: {rationale in 1 line}

## Context for next session
- {insight or preference that isn't in state files}
- {mental model or approach being used}

## Suggested first action
{1 concrete thing to do next, ready to execute}
```

### Step 3: Update state files (silent)

- Mark completed tasks in `tasks.md`
- Post any critical signals to `context-bus.md`
- Update `daily-log.md` if energy/wins were mentioned but not logged

### Step 4: Confirm to user

```
✅ Handoff saved. Następna sesja zacznie od:
→ {suggested first action}
{1-line summary of what's in progress}
```

## Rules
- MAX 20 lines in handoff.md — concise, not comprehensive
- Focus on WHAT'S NOT IN STATE FILES — don't repeat tasks.md content
- Overwrite previous handoff — only latest matters
- If /evening runs in same session → /wrap-up adds handoff on top, doesn't replace /evening
- Language: match user's language (Polish for [user])
