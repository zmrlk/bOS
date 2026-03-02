# bOS Privacy

This is a plain-language explanation of what bOS knows about you, where it lives, and what you can do with it. No legal jargon — just the facts.

---

## What bOS collects

### Your profile (`profile.md`)
When you set up bOS, it creates a profile file. It may include:

- **Who you are:** name, preferred name, location, timezone, language
- **Your situation:** job/work type (employee, freelancer, business owner, student), income range, financial goals
- **Your life context:** primary goals, what you want help with (business, health, habits, learning)
- **Your preferences:** communication style (direct, detailed, warm), how you like advice delivered
- **How you work:** peak energy hours, work schedule, weekly hours available
- **Your health setup:** fitness level, gym access, dietary approach, sleep goals — only if you activated the Health pack
- **Your subscriptions & benefits:** benefit cards (Multisport, Medicover), streaming services, AI tools, productivity tools — collected progressively through conversations and scans
- **Your patterns:** what you've told bOS about yourself over time, from conversations

What profile.md does NOT contain: passwords, API keys, financial account numbers, or medical diagnoses. Those never go into profile.md.

### State files (`state/`)
Daily activity tracked in local markdown files:

| File | What's in it |
|------|-------------|
| `state/tasks.md` | Your tasks and to-dos |
| `state/finances.md` | Income, expenses, buffer balance |
| `state/habits.md` | Habit streaks, milestones, personal bests |
| `state/pipeline.md` | Leads, clients (if Business pack active) |
| `state/decisions.md` | Key decisions with reasoning and review dates |
| `state/weekly-log.md` | Weekly review entries |
| `state/goals.md` | Long-term goals and milestones |
| `state/daily-log.md` | Daily energy, sleep, mood |
| `state/projects.md` | Active projects and hours (if Business pack active) |
| `state/journal.md` | Micro-journal entries from /reflect (questions + your answers) |
| `state/network.md` | Relationship contacts — names, context, follow-up dates |
| `state/context-bus.md` | Cross-agent context signals |
| `state/invoices.md` | Invoice records — numbers, amounts, clients, payment status |
| `state/time-log.md` | Time tracking entries — project, duration, description |
| `state/inbox.md` | Messages from connected channels (Telegram, Email, Slack, Discord, WhatsApp) — sender, subject, status |
| `state/schedules.md` | Automated skill schedules — which skills run when, delivery channel |
| `state/marketplace.md` | Installed marketplace skills — skill name, version, install date |

### Agent memory (`~/.claude/agent-memory/`)
Each agent you talk to remembers things about you across sessions. For example, @coach might remember you're a sprinter-type who needs short tasks. @finance might remember you tend toward impulse purchases.

This is stored in `~/.claude/agent-memory/` — separate from bOS itself, managed by Claude Code.

### Cross-agent signals (`state/context-bus.md`)
Agents share relevant information with each other to coordinate better. For example, when your stress is high, @wellness signals @finance to watch for impulse spending. When your budget is tight, @finance signals all agents to avoid recommending paid tools. These signals contain only the relevant data point — not your full profile or history.

### Webhook configuration (`state/.webhooks.md`)
If you use `/webhooks` to connect bOS to external tools (n8n, Zapier, Make), the webhook URLs and event mappings are stored in this file. bOS never logs full webhook URLs in cross-agent signals (they may contain tokens). Webhook execution is fire-and-forget — bOS sends a JSON payload when events occur but does not store responses.

### Secrets vault (`.secrets/vault.json`)
API keys and credentials you store via `/vault`. Stored locally only, protected so only your account can read them. Never sent anywhere.

### File scan data
During setup, if you give permission, bOS scans file and folder **names** (not contents) in your Desktop, Documents, Downloads, and Applications. It uses this to understand who you are and what tools you use. It does not read file contents, ever.

bOS also checks file modification dates to determine which tools and projects are currently active vs. abandoned. Old files (365+ days) are treated as archived and won't trigger tool recommendations.

---

## Subscription & benefit detection

When you run `/scan-context` or `/evolve` (with your consent), bOS may search for subscription-related information:

### What it looks for
- **Email patterns** (if Gmail/email connected): Searches for emails from known subscription providers by sender domain. It does NOT read email content — only checks if emails from specific senders exist.
- **Specific domains searched:** Benefit providers (benefitsystems.pl, medicover.pl, lux-med.pl, etc.), streaming services (netflix.com, spotify.com), AI tools (anthropic.com, openai.com), productivity tools (notion.so, figma.com).
- **App presence:** Checks installed applications (names only) to infer likely subscriptions.
- **Calendar patterns:** Recurring events at gyms, clinics, or studios may indicate memberships.

### What it does NOT do
- Does NOT read email content or bodies — only checks for sender domains
- Does NOT access bank accounts or payment providers
- Does NOT share subscription data with any external service
- Does NOT auto-sign up for anything

### How results are stored
- Detected subscriptions are stored in `profile.md → Subscriptions & Benefits` table
- Items detected through scanning are marked as "inferred" until you confirm them
- You can edit or remove any entry at any time

---

## Where it lives

**Lite Mode (default):** Everything stays on your computer. `profile.md`, state files, `.secrets/` — all local. Nothing leaves your machine.

**Pro Mode (Supabase connected):** Your task data, financial logs, habits, and agent memory get stored in a Supabase database. This is a cloud database — you set it up yourself with your own account. bOS uses your own database, not a shared one.

**Hybrid Sync (v0.6.0+):** When Supabase is connected, bOS uses a dual-write protocol — data is always written locally first, then pushed to Supabase. If you're offline, everything works normally. Changes sync automatically when you reconnect. Conflict resolution: small differences are auto-merged, larger conflicts ask you to decide. Sync metadata (timestamps, not content) is tracked in `sync_log` and `sync_state` Supabase tables.

In both modes, your secrets vault stays local. It never syncs to Supabase.

---

## Who can access your data

**Lite Mode:** Only you. The files are on your computer. If someone has access to your computer, they have access to these files. The `.secrets/` folder is protected so only your account can read them.

**Pro Mode:** You + your Supabase account. Supabase enforces Row Level Security — your data is tied to your authenticated user, and no one else can read it through the API.

**Claude / Anthropic:** Claude processes your messages to give responses. [Anthropic's privacy policy](https://www.anthropic.com/privacy) governs how conversations are handled. bOS does not send your local files to Anthropic — Claude Code reads them locally when needed for context.

---

## How long it persists

Data stays until you delete it. There's no automatic expiration.

- Profile, state files, secrets vault: until you run `/delete-my-data` or delete the files manually
- Agent memory: until you clear it (`~/.claude/agent-memory/` — delete the folder)
- Supabase data (Pro mode): until you delete it from your Supabase dashboard, or until you drop the tables

---

## Exporting your data

Run `/export` to create a full backup of everything bOS knows about you:
- Your profile
- All state files
- Secrets (field names only, values masked)
- Agent memory summary

This creates a single `bos-export-YYYY-MM-DD.md` file you can keep as a backup or use to migrate to another setup.

---

## Deleting your data

Run `/delete-my-data` to wipe everything:
- Deletes `profile.md`
- Resets state files to blank templates
- Clears `.secrets/vault.json`
- Does NOT delete agent memory automatically (that's in `~/.claude/agent-memory/` — you can delete that folder yourself)
- Does NOT delete Supabase data automatically — you can drop tables from the Supabase dashboard

bOS will ask you to confirm before doing anything.

---

## File scanning

bOS only scans file and folder **names**. It never opens or reads file contents.

Specifically:
- It looks at names in Desktop, Documents, Downloads, Applications
- It does NOT read your documents, spreadsheets, PDFs, images, or any other file
- Scanning happens only with your explicit consent during setup or when you run `/scan`
- You can say no — bOS works fine without scanning
- File modification dates are checked to prioritize recent/active files

---

## Health data

If you activate the Health pack, bOS may store:
- Workout logs (type, duration, exercises)
- Meal logs (description, calories — only if you choose to track)
- Sleep quality and energy levels
- Habit streaks, milestones, and personal bests
- Energy patterns (day-of-week analysis from your daily logs)

This data is stored locally (Lite mode) or in your own Supabase database (Pro mode). It is not shared with health platforms, insurance companies, or anyone else.

For serious health concerns, bOS will always recommend talking to a real doctor. It is not a medical device.

---

## Mobile access (optional)

bOS supports two ways to use it from your phone.

### Option A: Remote Control (native)

If you use `claude remote-control`, here's how it works:

**Data path:**
```
Your phone → claude.ai/Claude app → Anthropic API → your local Claude Code session → back the same way
```

**What stays local:** Everything. Your files, MCP connections, agent memory, secrets vault — all accessed locally by Claude Code on your computer. The phone is just a remote screen.

**Who has access:**
- **Anthropic:** Routes messages between your phone and your local session (Anthropic's privacy policy applies)
- **No other services involved** — no n8n, no Telegram, no Supabase needed

**Requirements:** Claude Max plan, computer must be on with Claude Code running.

**How to disconnect:** Close the terminal session. The remote connection ends immediately.

---

### Option B: Telegram Bot (advanced)

If you connect Telegram via `/connect-mobile`, here's how your data flows:

### Data path

```
Your phone → Telegram servers → n8n (your account) → Supabase (your database) → Claude API → back the same way
```

### What goes through Telegram
- Your messages to the bot (commands, text, expense logs)
- Bot responses (briefings, status, task lists)
- These are plain text messages — no files, no images, no documents

### What stays on your computer
- Full agent conversations (deep work sessions in Claude Code)
- File scans and local context
- Secrets vault (API keys, passwords)
- Agent configuration and system files
- Profile.md (complete profile — Telegram only sees what it needs per request)

### Who has access
- **Telegram:** Can see your messages to/from the bot (Telegram's privacy policy applies)
- **n8n:** Processes your messages (your own account — n8n Cloud or self-hosted)
- **Supabase:** Stores your data (your own database — you control it)
- **Claude API / Anthropic:** Processes messages to generate responses (Anthropic's privacy policy applies)

### How to disconnect
1. Delete the Telegram bot via @BotFather (`/deletebot`)
2. Deactivate n8n workflows
3. In bOS, say "disconnect mobile" — updates your profile

Your Supabase data and local bOS data remain intact after disconnecting Telegram.

### Recommendation
Telegram is a convenience layer — don't share sensitive information (passwords, financial account numbers) through the bot. Use the computer interface for sensitive conversations and the `/vault` for storing secrets.

---

## Webhooks and external integrations

If you configure webhooks via `/webhooks`, bOS sends event data (like "task completed" or "budget exceeded") to URLs you specify. This means data leaves your machine and goes to whatever service you connected (n8n, Zapier, Make, or a custom endpoint).

**What gets sent:** Event type, timestamp, and relevant data (task name, expense amount, habit streak, etc.). Test payloads are clearly marked with `"test": true`.

**What does NOT get sent:** Your full profile, passwords, health details, journal entries, or any data beyond the specific event.

**You control everything:** You choose which events to hook, where they go, and you can remove them anytime with `/webhooks remove`.

---

## Relationship data (network.md)

If you use `/network`, bOS stores names, context (how you know someone), and follow-up dates in `state/network.md`. This is private — bOS never shares contact information outside the local system. No data from network.md is sent to external services (unless you configure a webhook for it).

---

## Journal entries (journal.md)

If you use `/reflect`, bOS stores your micro-journal entries (a question and your answer) in `state/journal.md`. These are private reflections. After 30+ entries, @coach may identify patterns during your weekly review — but this analysis stays local.

---

## Unified Inbox data

If you use `/inbox`, bOS collects messages from connected channels (Telegram, Email, Slack, Discord, WhatsApp) via n8n workflows. Messages are stored in `state/inbox.md` (Lite mode) or the `messages` Supabase table (Pro mode). Message data includes: sender name, channel, subject/preview, and timestamps. Full message bodies are stored only in Pro mode. Messages can be archived or deleted via `/inbox archive`.

## Scheduled skill data

If you use `/schedule`, bOS stores your automation schedules in `state/schedules.md` (Lite mode) or the `schedules` Supabase table (Pro mode). This includes: which skills run, when (cron expression), and where they deliver (in-app, Telegram, email). No personal data is stored in schedules — only configuration.

## Marketplace data

If you use `/marketplace`, bOS tracks which skills you've installed in `state/marketplace.md`. This includes: skill name, version, and install date. No personal data is shared with the skill registry — bOS fetches the catalog from GitHub (public repo) without sending any user information.

---

## What bOS does NOT do

- bOS does not sell your data. All your information stays on your computer (or in your own private database if you connect one). There is no central server, no analytics, no tracking.
- It does not share your information with third parties (unless you explicitly configure webhooks to external services).
- It does not send your files anywhere without your explicit action.
- It does not track you across websites or apps.
- It does not store payment card numbers or bank credentials.
- It does not send marketing emails or notifications without you setting that up.
- It does not read email content — only checks for sender domains during subscription detection (with your consent).

---

## Questions?

bOS is an open system — you can read every file it creates. If you're ever unsure what's stored, just look in:
- `profile.md` — your profile
- `state/` — your activity data
- `.secrets/vault.json` — your secrets (open the file to inspect it)
- `~/.claude/agent-memory/` — agent memory

Everything is readable text. Nothing is hidden.
