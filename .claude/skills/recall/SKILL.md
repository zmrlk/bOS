---
name: Recall
description: "Search across all past bOS sessions — session digests, memory files, pre-compact snapshots, state files, and context-bus history. Use this skill whenever the user says /recall, 'remember when', 'last time we', 'we talked about', 'what did we decide', 'find that conversation', or references something from a previous session. Also trigger when user seems confused about past context or asks 'did I already...' or 'have we...'. This is the go-to skill for recovering any information from past sessions."
user_invocable: true
command: /recall
---

# /recall — Cross-Session Memory Search

**Shortcuts:** `/recall`, `rc`
**NLP triggers:** "remember when", "last time we", "we talked about", "what did we decide", "przypomnij", "co ustaliliśmy", "did I already", "have we"

Search everything bOS remembers across sessions. Powered by @boss.

The user loses context between Claude Code sessions. This skill bridges that gap by searching all persistent stores where past session data lives.

---

## Search Sources (priority order)

Search ALL sources in parallel. Each source has different strengths:

| Source | Path | What it captures | Best for |
|--------|------|-----------------|----------|
| **Session digests** | `state/.backup/session-digests/` | Topic, decisions, open threads per session | "What did we decide about X?" |
| **Memory files** | `~/.claude/projects/<project-dir>/memory/` | Persistent facts, patterns, feedback | "What do you know about X?" |
| **Pre-compact snapshots** | `state/.backup/pre-compact-*.md` | State at moment of context compaction | Recovering mid-session context |
| **Context bus** | `state/context-bus.md` | Inter-agent signals, decisions | "When did agent X say Y?" |
| **Session log** | `state/session-log.md` | Timestamps of sessions | "When was our last session?" |
| **State files** | `state/*.md` | Tasks, finances, habits, goals, etc. | "What task did we add for X?" |
| **Agent memory** | `~/.claude/agent-memory/*/` | Agent-specific observations (cto/, boss/, etc.) | Agent behavioral patterns |
| **Project memory** | `~/.claude/projects/<project-dir>/memory/` | Project-scoped persistent memory | Cross-session facts, MEMORY.md index |

---

## Protocol

### Step 1: Understand the query
Parse what the user is looking for:
- **Topic search** ("remember that thing about Lightpanda") → keyword search across all sources
- **Decision search** ("what did we decide about pricing") → focus on digests + context-bus
- **Time search** ("last week's session") → focus on digests by date
- **State search** ("did I already log that expense") → focus on state files

### Step 2: Search (all parallel, one turn)

```
Glob: state/.backup/session-digests/*.md
Grep: [user's keywords] across all sources
Read: MEMORY.md for index of memory files
```

Use multiple Grep calls in parallel across different source directories. Search for:
1. Exact keywords from the user's query
2. Synonyms / related terms (e.g., "Lightpanda" → also search "browser", "headless", "panda")
3. Date patterns if time-based query

### Step 3: Synthesize results

Present findings as:
```
🔍 @Boss — Recall: [topic]

Found in [N] sources:

📝 Session [date]: [relevant excerpt]
💾 Memory: [relevant memory file + content]
📋 State: [relevant state entry]

Context: [synthesized answer to user's question]
```

### Rules
- Always show WHERE the information was found (source + date) so user can verify
- If nothing found → say so clearly: "Nie znalazłem tego w żadnym ze źródeł. Może to było w sesji która nie miała digestu (przed v0.9.1)?"
- If partial match → show what you found + ask for clarification
- If multiple sessions mention the topic → show chronological progression
- Never fabricate recalled information — only report what's actually in the files
- Keep synthesis concise — user wants the answer, not a tour of the search process

### Step 4: Offer follow-up
After recall, offer:
- "Chcesz żebym zapisał to do memory żeby nie stracić?"
- "Chcesz kontynuować tę robotę?"
