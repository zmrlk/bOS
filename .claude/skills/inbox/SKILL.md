---
name: Unified Inbox
description: "View and manage messages from all channels (Telegram, Email, Slack, Discord, WhatsApp) in one place. Route messages to agents, reply through original channels."
user_invocable: true
command: /inbox
---

# /inbox — Unified Inbox

All your messages. One place. Route to agents. Reply through original channel.

---

## Usage

- `/inbox` — show unread messages grouped by channel
- `/inbox [channel]` — filter by channel (telegram, email, slack, discord, whatsapp)
- `/inbox reply [id]` — compose reply, send through original channel
- `/inbox route [id] @agent` — route message to a specific agent for handling
- `/inbox archive` — archive all read messages
- `/inbox setup` — configure a new inbox channel

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language, inbox_channels, dnd_hours
- `state/inbox.md` (Tier 1: first 25 lines → Summary) → unread count
- If Pro mode → query `messages` table instead

If `state/inbox.md` doesn't exist → create silently with schema from `state/SCHEMAS.md` (inbox.md section).

### Step 2: Mode detection

- **Pro mode** (Supabase connected): Read/write from `messages` table
- **Lite mode**: Read/write from `state/inbox.md` (growing file format)

---

### Subcommand: `/inbox` (default — show unread)

**Pro mode query:**
```sql
SELECT id, channel, sender_name, subject, body, created_at, status
FROM messages
WHERE status IN ('unread', 'read', 'routed')
ORDER BY created_at DESC
LIMIT 20;
```

**Lite mode:** Read Active section of `state/inbox.md`.

**Display format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📬  INBOX — [X] unread
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📱 Telegram ([N] unread)
  ┌──────────────────────────────────┐
  │ [sender] — [preview 60 chars]   │
  │ [sender] — [preview 60 chars]   │
  └──────────────────────────────────┘

  📧 Email ([N] unread)
  ┌──────────────────────────────────┐
  │ [sender] — [subject]            │
  │ [sender] — [subject]            │
  └──────────────────────────────────┘

  💬 Slack ([N] unread)
  ┌──────────────────────────────────┐
  │ [sender] — [preview 60 chars]   │
  └──────────────────────────────────┘

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If inbox is empty:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📬  INBOX — all clear
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  No unread messages.

  Channels: [list connected or "none yet"]

  → /inbox setup to connect a channel
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Follow-up:** AskUserQuestion with options:
- "Reply to a message" → prompt for ID, then `/inbox reply`
- "Route to agent" → prompt for ID + agent
- "Archive read" → `/inbox archive`
- "Done"

---

### Subcommand: `/inbox [channel]`

Filter by channel. Same display as above but only one channel.

Valid channels: `telegram`, `email`, `slack`, `discord`, `whatsapp`.

If user provides invalid channel → "Unknown channel. Available: telegram, email, slack, discord, whatsapp."

---

### Subcommand: `/inbox reply [id]`

1. **Load message** — fetch by ID (Pro: SQL query, Lite: find in inbox.md)
2. **Show context:**
   ```
   📨 Replying to [sender] via [channel]
   ┌────────────────────────────────────┐
   │ [full message body]               │
   └────────────────────────────────────┘
   ```
3. **Compose reply** — ask user for reply text (open text field)
4. **Send:**
   - **Pro mode:** Update message row: `response = [text]`, `status = 'reply_pending'`, `replied_at = NOW()`
     The outbox-router n8n workflow picks up `reply_pending` and sends through the original channel.
   - **Lite mode:** Note the reply in inbox.md. Inform: "Reply saved. To send it, you'll need n8n outbox-router connected. /inbox setup for help."
5. **Confirm:** "Reply sent via [channel] to [sender]."
6. **Webhook:** Fire `message.replied` event if configured.

---

### Subcommand: `/inbox route [id] @agent`

1. **Load message** by ID
2. **If @agent not specified** → suggest agent based on message content:
   - Keywords: "faktura/invoice/payment" → @cfo
   - Keywords: "spotkanie/meeting/call" → @coo
   - Keywords: "bug/code/error/deploy" → @devlead
   - Keywords: "content/post/marketing" → @cmo
   - Keywords: "lead/deal/client" → @sales
   - Default → @boss
   Use AskUserQuestion with top 3 suggestions + "Other"
3. **Route:**
   - Update message: `routed_agent = @agent`, `status = 'routed'`
   - Post to context-bus: `@boss → @[agent], Type: data, Priority: normal, Content: "Inbox message from [sender] via [channel]: [preview]"`
4. **Confirm:** "Message routed to @[agent]. They'll see it next session."

### Auto-routing (if `inbox_auto_route = on` in profile.md)

On session-start, @boss checks unread messages and auto-routes based on keyword matching:

| Keywords | Route to |
|----------|----------|
| faktura, invoice, payment, rachunek, płatność | @cfo |
| spotkanie, meeting, call, zoom, teams | @coo |
| bug, error, code, deploy, server, API | @devlead |
| content, post, social, marketing, campaign | @cmo |
| lead, deal, client, prospect, sale | @sales |
| task, projekt, deadline, termin | @coo |

Auto-routed messages get `status = 'routed'` and a context-bus signal. User sees in session-start nudge: "📬 [X] messages auto-routed. /inbox to review."

---

### Subcommand: `/inbox archive`

1. **Pro mode:** `UPDATE messages SET status = 'archived' WHERE status IN ('read', 'replied');`
2. **Lite mode:** Move read/replied entries from Active to Archive section of inbox.md
3. **Report:** "Archived [X] messages."

---

### Subcommand: `/inbox setup`

Guide user through connecting a new inbox channel.

1. AskUserQuestion:
   - header: "Channel"
   - options:
     - "Telegram" (description: "Receive Telegram messages in bOS")
     - "Email" (description: "Poll email via IMAP")
     - "Slack" (description: "Listen to Slack channel messages")
     - "Discord" (description: "Discord bot integration")

2. Based on selection, guide through n8n workflow setup:
   - Show the relevant template from `templates/n8n/`
   - Walk through credentials setup step by step
   - Adapt instructions to `tech_comfort`:
     - "I code" → show JSON, explain n8n nodes
     - "I use apps" → step-by-step with screenshots references
     - "not technical" → "This needs n8n (automation tool). I'll walk you through it. It takes ~10 minutes."

3. After setup:
   - Update `profile.md → inbox_channels` to include new channel
   - Test: send a test message → verify it appears in inbox

---

## Lite Mode Fallback

When Supabase is not connected, inbox uses `state/inbox.md` (growing file format).

### inbox.md Schema (Growing file — Summary/Active/Archive)

```markdown
# Inbox

## Summary
<!-- AUTO-UPDATED by @boss at session end -->
Active section: lines XX-YY
| Metric | Value |
|--------|-------|
| Unread | X |
| Total active | X |
| Channels | telegram, email |

---

## Active

| ID | Channel | Sender | Subject/Preview | Status | Date |
|----|---------|--------|-----------------|--------|------|
| 1 | telegram | Jan K. | Hej, masz chwilę? | unread | 2026-03-02 |
| 2 | email | newsletter@ai.com | Weekly AI digest | read | 2026-03-02 |

---

## Archive
[older messages moved here]
```

**Note:** In Lite mode, messages must be manually added (or via n8n writing to the file). The skill works as a viewer/manager regardless.

---

## DND Hours

If `profile.md → dnd_hours` is set (e.g., "22:00-07:00"):
- Auto-routing still happens (messages are categorized)
- But NO nudges about new messages during DND hours
- Messages are silently accumulated and presented at next active session

---

## State Write Protocol

- **Owner:** @boss (inbox.md and messages table)
- **Readers:** all agents (for routed messages)
- @boss writes inbox.md Summary at session end (lazy)
- Individual message status updates happen immediately (reply, route, archive)

---

## Cross-Agent Signals

### I POST when:
- New message received with auto-route match → target agent
- High-priority message detected (keywords: urgent, pilne, ASAP) → @boss + target agent, Priority: critical
- Inbox overflow (20+ unread) → @boss, Priority: normal

### I LISTEN for:
- Agent responses to routed messages → update message status
- DND schedule changes from @organizer/@wellness

---

## Webhook Events

- `message.received` — fires when a new message enters the inbox
- `message.replied` — fires when a reply is sent through any channel
