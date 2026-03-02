---
name: Webhooks
description: "bOS Event System — connect your life OS to external tools. Automate actions when things happen in bOS."
user_invocable: true
command: /webhooks
---

# /webhooks — bOS Event System

Connect bOS to the outside world. When something happens here, trigger something there.

---

## Usage

- `/webhooks` — list active webhooks
- `/webhooks add` — create new webhook (guided)
- `/webhooks remove` — remove a webhook
- `/webhooks test` — test fire a webhook

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `profile.md` (full) → language
- `state/.webhooks.md` (full, infrastructure file) → existing webhooks

If .webhooks.md doesn't exist → create with schema:
```
# Webhooks

## Active

| Event | URL | Method | Headers | Status |
|-------|-----|--------|---------|--------|

## Log

Last 10 fires (auto-trimmed).

| Date | Event | URL | Status code | Latency |
|------|-------|-----|-------------|---------|
```

### Subcommand: `/webhooks` (list)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔗  WEBHOOKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Active: [X] webhooks

  1. [event] → [URL] ([status])
  2. [event] → [URL] ([status])

  Last fires:
  → [date] [event] → [status code] ([latency]ms)
  → [date] [event] → [status code] ([latency]ms)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Subcommand: `/webhooks add`

1. Use `AskUserQuestion`:
   - header: "Event"
   - options:
     - "task.completed" (description: "Gdy task zostanie ukończony")
     - "expense.logged" (description: "Gdy zalogujesz wydatek")
     - "habit.milestone" (description: "Gdy osiągniesz milestone nawyku")
     - "budget.exceeded" (description: "Gdy przekroczysz budżet kategorii")

2. If user needs more events, offer second set:
   - "energy.crash" (description: "Gdy energia spadnie ≥3 punkty")
   - "sprint.completed" (description: "Gdy sprint się zakończy")
   - "decision.review_due" (description: "Gdy nadejdzie termin review decyzji")

3. If user needs inbox/invoice events, offer third set:
   - "message.received" (description: "Gdy nowa wiadomość trafi do inbox")
   - "message.replied" (description: "Gdy odpowiesz na wiadomość")
   - "invoice.created" (description: "Gdy stworzysz fakturę")
   - "invoice.overdue" (description: "Gdy faktura będzie zaległa")

3. Ask for webhook URL (typed input): "Podaj URL webhooka (np. n8n, Make, Zapier):"

4. Use `AskUserQuestion`:
   - header: "Metoda"
   - options:
     - "POST (Recommended)" (description: "Standardowy webhook — JSON body z danymi")
     - "GET" (description: "Prosty ping — dane w query params")

5. Optional: Ask for custom headers (typed, or skip)

6. Save to `.webhooks.md` Active table

7. Confirm: "✅ Webhook dodany: [event] → [URL]. Użyj `/webhooks test` żeby sprawdzić."

### Subcommand: `/webhooks remove`

1. Show numbered list of active webhooks
2. Ask which to remove (typed number)
3. Remove from `.webhooks.md`
4. Confirm: "✅ Usunięto webhook: [event] → [URL]."

### Subcommand: `/webhooks test`

1. Show active webhooks, ask which to test
2. Fire test payload:
   ```json
   {
     "event": "[event_type]",
     "test": true,
     "timestamp": "[ISO date]",
     "data": {"message": "bOS webhook test"}
   }
   ```
3. Report result: status code + latency
4. Log to `.webhooks.md` Log table

## Supported Events

| Event | Trigger | Payload |
|-------|---------|---------|
| `task.completed` | Task marked done | `{task_name, completed_at}` |
| `expense.logged` | /expense logged | `{amount, category, currency}` |
| `habit.milestone` | Streak milestone hit | `{habit, streak, milestone}` |
| `budget.exceeded` | Category > 100% | `{category, spent, budget, percent}` |
| `energy.crash` | Energy drop ≥ 3 points | `{from, to, date}` |
| `sprint.completed` | Sprint week ends | `{planned_sp, completed_sp, velocity}` |
| `decision.review_due` | Review date reached | `{title, decided_at, verdict}` |
| `invoice.created` | New invoice generated | `{invoice_number, client, amount, currency}` |
| `invoice.overdue` | Invoice past due date | `{invoice_number, client, amount, days_overdue}` |
| `invoice.paid` | Invoice marked as paid | `{invoice_number, client, amount, paid_date}` |
| `code.shipped` | Code pipeline completed | `{project, branch, quality_score}` |
| `proposal.sent` | Proposal sent to client | `{client, project, amount}` |
| `timer.stopped` | Time tracker stopped | `{project, duration, description}` |
| `message.received` | New message in inbox | `{channel, sender, preview}` |
| `message.replied` | Reply sent via channel | `{channel, sender, response_preview}` |

## Context-Bus Signals

No signals — infrastructure skill, not agent-driven.

## State Files
- **Read:** profile.md, .webhooks.md (full)
- **Write:** .webhooks.md

## Rules
1. Use AskUserQuestion for all choices
2. All reads in 1 turn (parallel I/O)
3. Webhook URLs must start with https:// (security)
4. Never log full webhook URLs in context-bus (may contain tokens)
5. Fire-and-forget: don't block on webhook response
6. Log table auto-trimmed to last 10 entries
7. Test fires include `"test": true` flag so receivers can filter
8. @boss dispatches webhook fires after matching state writes
9. Language matches user's profile language
