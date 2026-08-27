---
name: recall
description: "Search durable bOS memory, live state, and session history with source locators. Use for /recall, 'remember when', 'what did we decide', 'did I already', or any cross-session fact recovery."
user_invocable: true
command: /recall
tier: core
---

# /recall — Cross-Session Memory Search

**Shortcuts:** `/recall`, `rc`
**NLP triggers:** "remember when", "last time we", "we talked about", "what did we decide", "did I already", "have we"

Search everything bOS remembers across sessions. Powered by @boss.

Start with the canonical, vendor-neutral durable store. Session history is
evidence of what was said, not automatically a current fact.

---

## Search Sources (priority order)

Search sources in this order; independent searches may run in parallel:

| Source | Path | What it captures | Best for |
|--------|------|-----------------|----------|
| **Durable memory** | `bash scripts/bos-memory.sh recall "<query>"` | Confirmed/verified records with status and provenance | "What do you know about X?" |
| **Live state** | `state/*.md` | Current tasks, finances, habits, goals | "Did I log/do X?" |
| **Session digests** | `state/.backup/session-digests/` | Lossy record of topics and decisions | "What did we discuss?" |
| **Pre-compact snapshots** | `state/.backup/pre-compact-*.md` | State at moment of context compaction | Recovering mid-session context |
| **Context bus** | `state/context-bus.jsonl` | Inter-agent signals, decisions | "When did agent X say Y?" |
| **Session log** | `state/session-log.md` | Timestamps of sessions | "When was our last session?" |
| **Claude auto-memory** | `~/.claude/projects/<project>/memory/` | Optional, host-specific hints | Claude-only fallback |

---

## Protocol

### Step 1: Understand the query
Parse what the user is looking for:
- **Topic search** ("remember that thing about that headless browser") → keyword search across all sources
- **Decision search** ("what did we decide about pricing") → focus on digests + context-bus
- **Time search** ("last week's session") → focus on digests by date
- **State search** ("did I already log that expense") → focus on state files

### Step 2: Search (all parallel, one turn)

```
bash scripts/bos-memory.sh recall "<keywords>"
Grep: [user's keywords] across state and session-history sources
```

Use multiple Grep calls in parallel across different source directories. Search for:
1. Exact keywords from the user's query
2. Synonyms / related terms (e.g., "that headless browser" → also search the product name, "browser", "headless")
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
- Always show WHERE the information was found (locator + source/date)
- Current durable memory outranks a session digest; an unresolved conflict must
  be shown, not silently resolved
- Stale/archived records are historical, never phrased as current
- If nothing found → say so clearly: "I couldn't find this in any source. It may have been in a session that left no digest."
- If partial match → show what you found + ask for clarification
- If multiple sessions mention the topic → show chronological progression
- Never fabricate recalled information — only report what's actually in the files
- Keep synthesis concise — user wants the answer, not a tour of the search process

Do not claim semantic/vector search. The shipped helper is deterministic lexical
search. If nothing matches it prints `MEMORY-NONE`; keep that honest wording.
