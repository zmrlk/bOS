---
name: Invoice Management
description: "Create, track, and manage invoices. Generate payment reminders. Use when the user needs to invoice a client, check outstanding invoices, or send payment reminders."
user_invocable: true
command: /invoice
model: haiku
---

# /invoice — Invoice Management

Create, track, and manage invoices for your business. Powered by @cfo.

**Adapt to tech_comfort:** "not technical" → simple language, no accounting terms. "I use apps" → name tools. "I code" → technical details OK.

---

## Subcommands

| Command | What it does | When to use |
|---------|-------------|------------|
| `/invoice create` | Guided invoice creation from pipeline/projects data | New invoice |
| `/invoice list` | Outstanding invoices with status | Quick overview |
| `/invoice remind [number]` | Generate payment reminder text | Overdue invoice |
| `/invoice mark-paid [number]` | Update invoice status to paid | Payment received |

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → business name, currency, NIP/tax ID
- `state/projects.md` (full) → active projects, hours, rates
- `state/pipeline.md` (full) → client context
- `state/invoices.md` (full) → existing invoices

---

## /invoice create — Guided Creation

### Protocol:
1. Batch read: profile.md, projects.md, pipeline.md, invoices.md
2. `AskUserQuestion`:
   - header: "Client"
   - options: [list clients from pipeline.md + "New client"]
3. `AskUserQuestion`:
   - header: "Project"
   - options: [list projects from projects.md for selected client + "New project"]
4. Auto-fill from projects.md: rate, hours, total
5. `AskUserQuestion`:
   - header: "Payment terms"
   - options:
     - "7 days"
     - "14 days" (description: "Standard")
     - "30 days"
     - "Custom"
6. Generate invoice number: auto-increment from last invoice in invoices.md (INV-001, INV-002, etc.)
7. Generate invoice markdown:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INVOICE [INV-XXX]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  From: [business name from profile.md]
  To: [client name]
  Date: [today]
  Due: [today + payment terms]

  ┌─────────────────────────────────┐
  │ Description         │ Amount   │
  │─────────────────────│──────────│
  │ [project/service]   │ [amount] │
  │ [hours]h × [rate/h] │          │
  │─────────────────────│──────────│
  │ TOTAL               │ [total]  │
  └─────────────────────────────────┘

  Payment: [bank details from profile or "Add payment details to profile"]
  Terms: [payment terms]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

8. Save to state/invoices.md
9. `AskUserQuestion`:
   - header: "Next"
   - options:
     - "Copy invoice" (description: "Copy-paste ready for email")
     - "Create another"
     - "Done"

---

## /invoice list — Outstanding Invoices

Show table from state/invoices.md:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💰 INVOICES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  | # | Client | Amount | Status | Due |
  |---|--------|--------|--------|-----|
  | INV-003 | Acme | 5,000 PLN | ⚠️ overdue | 2026-02-15 |
  | INV-004 | StartupXYZ | 3,000 PLN | 📤 sent | 2026-03-10 |
  | INV-005 | BigCorp | 8,000 PLN | 📝 draft | 2026-03-20 |

  Total outstanding: 16,000 PLN
  Overdue: 5,000 PLN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Status icons: 📝 draft | 📤 sent | ✅ paid | ⚠️ overdue

---

## /invoice remind [number] — Payment Reminder

1. Read invoice from invoices.md
2. Generate ready-to-send reminder text:

```
📧 PAYMENT REMINDER — ready to send:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Subject: Payment reminder — Invoice [INV-XXX]

Hi [client name],

I wanted to follow up on invoice [INV-XXX] for [amount],
which was due on [date]. Could you let me know the
status of the payment?

If already paid — please disregard this message.

Thank you,
[your name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## /invoice mark-paid [number] — Mark as Paid

1. Update invoice status in invoices.md to "paid"
2. Set paid date to today
3. Confirm: "✅ Invoice [INV-XXX] marked as paid."

---

## Context-Bus Signals

After invoice creation:
```
@cfo → @sales, Type: data, Priority: info, TTL: 14 days
Content: Invoice INV-[XXX] created for [client]. Amount: [X]. Due: [date].
Status: pending
```

---

## State Files
- **Read:** profile.md, projects.md, pipeline.md, invoices.md
- **Write:** invoices.md (new invoices, status updates)

---

## Rules

1. Invoice numbers auto-increment (INV-001, INV-002...)
2. All reads in 1 batch turn
3. Use AskUserQuestion for all choices
4. Always show total outstanding and overdue amounts in /invoice list
5. Reminder text is copy-paste ready
6. Currency from profile.md
7. Language matches user's language from profile.md
8. Max 2 context-bus signals per execution
