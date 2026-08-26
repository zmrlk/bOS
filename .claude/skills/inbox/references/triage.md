<!-- Loaded by inbox/SKILL.md — reference detail, not a skill. -->

# /inbox — filters, categories, formats

## Email accounts

| Account | Connector | Type |
|---------|-----------|------|
| Gmail | claude.ai Gmail | filled in `/setup` |
| Outlook | Microsoft 365 | filled in `/setup` |

## Gmail — category filters

| Category/Label | Triage behavior |
|----------------|-----------------|
| `CATEGORY_PROMOTIONS` | **Skip** — never show in triage |
| `CATEGORY_SOCIAL` | **Skip** — never show in triage |
| Label `9: newsletter` | **Skip in quick triage**, summarize in full triage |
| Label `10: marketing` | **Skip** |
| Label `1: urgent` | **ALWAYS show** — top priority |
| Label `2: action needed` | **ALWAYS show** — high priority |
| Label `8: payment` | **ALWAYS show** — financial |
| Label `3: follow up` | Show if unread |

Post-fetch: drop promotions/social, keep ACTION/PAYMENT. Do not invent vendor-specific POS dashboards.

## Categorization criteria (both accounts)

| Category | Criteria | Icon |
|----------|----------|------|
| **ACTION** | Requires response or task from the user | 🔴 |
| **FYI** | Informational, no action needed | 🔵 |
| **DELEGATE** | Someone else should handle | 🟡 |
| **ARCHIVE** | Irrelevant or already handled | ⚪ |
| **PAYMENT** | Financial — invoice, payment, billing | 💰 |

Email mentioning money/expenses → flag PAYMENT. Email from a profile priority sender → flag as priority.

## Triage summary format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📬 INBOX TRIAGE — [date]
  Gmail: [X] new | Outlook: [Y] new
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 ACTION ([N]):
  1. 📧 [sender] — [subject] (1 line summary)
     → Suggestion: [reply/task/meeting]
  2. 📨 [sender] — [subject]
     → Suggestion: [action]

💰 PAYMENT ([N]):
  3. [sender] — [subject] → [amount if visible]

🔵 FYI ([N]):
  4. [sender] — [subject] (1 line)

🟡 DELEGATE ([N]):
  5. [sender] — [subject] → who: [person]

⚪ ARCHIVE: [count] emails skipped
```

Use 📧 for Gmail emails, 📨 for Outlook emails — so the user knows which inbox.

## Processing ACTION emails

For each ACTION email, AskUserQuestion: "[icon] [sender]: [subject summary]" — options: [Send draft reply] [Add as task] [Skip] [Show full email].

- **Send draft reply** → generate the draft in the user's style (direct, concise, in the email's language). Gmail: `gmail_create_draft`. Outlook: show draft text. Confirm: "📝 Draft saved — check it in Gmail/Outlook."
- **Add as task** → extract the task, append to `state/tasks.md`. Confirm: "✅ Task added: [task name]."

## Task extraction (all emails, not just ACTION)

Detect task-like content: deadlines ("by Friday", "deadline March 25"), requests ("please send", "we need"), meeting proposals ("meeting", "call"), payments due ("invoice", "payment due").

```
📋 Extracted tasks:
  → [task] (from email from [sender])
  → [task] (from email from [sender])
Add to tasks.md? [Yes, all] [Let me pick] [No]
```

## Closing quick action

AskUserQuestion at the end — "What next?" → [Reply to the first ACTION] [Check system-alert details] [Done].

## Integration with /morning and /evening

**Called from /morning:** compact format (summary only, no processing/extraction/quick-action steps), max 5 most important emails, bulk-sender counts in 1 line if configured.

**Called from /evening:** show unprocessed ACTION emails from today — "[N] emails left to deal with. Push to tomorrow?" [Yes] [I'll handle them now].
