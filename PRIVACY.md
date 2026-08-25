# bOS Privacy

This is a plain-language explanation of what **Lite bOS (this repo, v0.12.1)** knows about you. No legal jargon.

Lite is a **local folder**. It does not run a 24/7 daemon. Optional samples live under `examples/` and are off unless you copy them in. There is no `/vault` skill and no `/delete-my-data` skill in Lite — delete files yourself, or use your OS.

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
| `state/context-bus.jsonl` | Cross-agent context signals (append via helper only) |
| `state/invoices.md` | Invoice records — numbers, amounts, clients, payment status |
| `state/time-log.md` | Time tracking entries — project, duration, description |
| `state/inbox.md` | Messages from connected channels (Telegram, Email, Slack, Discord, WhatsApp) — sender, subject, status |
| `state/schedules.md` | Only if you copy `examples/skills/schedule/` — not Lite |
| `state/marketplace.md` | Not used by Lite (no skill registry) |
| `state/.engagement-log.md` | Session timestamps and directive outcomes — used by lifecycle hooks to detect first-session-of-day and track system health. Never stores message content or conversation text. |

### Auto-memory (`~/.claude/projects/<project>/memory/`)
Each agent you talk to remembers things about you across sessions. For example, @coach might remember you're a sprinter-type who needs short tasks. @finance might remember you tend toward impulse purchases.

This is stored in `~/.claude/projects/<project>/memory/` — separate from bOS itself, managed by Claude Code.

### Runtime marker files (`state/.*`)
Small dotfiles written by lifecycle hooks and skills during a session — for example `state/.last-message` (a timestamp) or `state/.working.md` (a crash buffer). They hold only what the hook needs to avoid repeating itself, they stay on your machine, and they are never synced to Supabase. All of them are gitignored, so they never travel with the distribution.

### Cross-agent signals (`state/context-bus.jsonl`)
Agents share relevant information with each other to coordinate better. For example, when your stress is high, the wellness perspective signals @finance to watch for impulse spending. When your budget is tight, @finance signals all agents to avoid recommending paid tools. These signals contain only the relevant data point — not your full profile or history. Write only through `bash scripts/context-bus-append.sh`. The markdown stub `state/context-bus.md` is not the live bus.

### Webhook configuration (`state/.webhooks.md`)
Lite has no `/webhooks` skill. If you add your own `state/.webhooks.md`, URLs may contain tokens — never copy them to the bus or chat.

### Secrets (`.secrets/`)
Create this folder yourself (`chmod 700`, files `600`). Never paste keys into chat. There is no `/vault` skill in Lite.

### Push notification config (`.secrets/ntfy.env`)
If you use push notifications via ntfy.sh, your topic name and server URL are stored in `.secrets/ntfy.env`. This file is local-only and never synced to Supabase or any external service.

### File scan data
During setup, if you give permission, bOS scans file and folder **names** (not contents) in your Desktop, Documents, Downloads, and Applications. It uses this to understand who you are and what tools you use. It does not read file contents, ever.

bOS also checks file modification dates to determine which tools and projects are currently active vs. abandoned. Old files (365+ days) are treated as archived and won't trigger tool recommendations.

---

## Subscription & benefit detection

When you run `/evolve` **and you consent to a file-name scan**, bOS may look for subscription-related **names** (not file contents):

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

**Lite (this repo):** Everything stays on your computer. `profile.md`, state files, `.secrets/` — all local. Nothing leaves your machine unless you send it (chat to Anthropic, or an optional ntfy topic you configured).

**Supabase / “Pro”:** sample schemas live in `examples/supabase/`. Lite does **not** dual-write to the cloud. If you copy those samples and connect a database yourself, that is your setup — not shipped behavior.

Secrets in `.secrets/` stay local. They are not synced anywhere by Lite.

---

## Who can access your data

**Lite Mode:** Only you. The files are on your computer. If someone has access to your computer, they have access to these files. The `.secrets/` folder is protected so only your account can read them.

**Your own cloud (optional):** only if you copy `examples/supabase/` and connect it. Not Lite.

**Claude / Anthropic:** Claude processes your messages to give responses. When Claude Code reads a local file (like your profile or state files), the relevant content is sent to Anthropic's API as part of the conversation context. [Anthropic's privacy policy](https://www.anthropic.com/privacy) governs how this data is handled. Your files are not stored separately on Anthropic's servers — they are processed as part of your conversation, subject to Anthropic's data retention policy.

---

## How long it persists

Data stays until you delete it. There's no automatic expiration.

- Profile, state files, `.secrets/`: until you delete the files yourself (Lite has no `/delete-my-data` skill)
- Agent memory: until you clear it (`~/.claude/projects/<project>/memory/` — delete the folder)
- Anything you put in your own Supabase (not Lite): until you delete it there

---

## Exporting your data

Lite has **no** `/export` skill. Copy `profile.md` and `state/*.md` yourself (or ask the agent to pack a zip). Do not copy `.secrets/` into chat.

---

## Deleting your data

To wipe everything, delete `profile.md`, `state/*.md`, and `.secrets/` yourself (ask the agent to list paths first):
- Deletes `profile.md`
- Resets state files to blank templates
- Clears `.secrets/` if present
- Does NOT delete agent memory automatically (that's in `~/.claude/projects/<project>/memory/` — you can delete that folder yourself)
- Does NOT delete Supabase data automatically — you can drop tables from the Supabase dashboard

bOS will ask you to confirm before doing anything.

---

## File scanning

bOS only scans file and folder **names**. It never opens or reads file contents.

Specifically:
- It looks at names in Desktop, Documents, Downloads, Applications
- It does NOT read your documents, spreadsheets, PDFs, images, or any other file
- Scanning happens only with your explicit consent during `/setup`
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

**Requirements:** Claude Pro or Max plan, computer must be on with Claude Code running.

**How to disconnect:** Close the terminal session. The remote connection ends immediately.

---

### Option B: Telegram (not Lite)

There is **no** `/connect-mobile` skill in this repo. Sample n8n flows live under `examples/templates/n8n/`. If you wire Telegram yourself, data may flow like this:

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
Telegram is a convenience layer — don't share sensitive information (passwords, financial account numbers) through the bot. Use the computer interface for sensitive conversations; store secrets in `.secrets/` with an editor, never in chat.

---

## Webhooks and external integrations

Lite has **no** `/webhooks` skill. If you add your own hooks, data you send leaves the machine. Keep payloads small; never put secrets in them.

---

## Push notifications (ntfy.sh)

If you enable push notifications, bOS uses [ntfy.sh](https://ntfy.sh) to send alerts to your phone.

**What gets sent:** Short text strings only — for example "Reminder: weekly review" or "Buffer alert: below target". No personal data, no file contents, no financial amounts, no conversation excerpts.

**Where it goes:** Messages are published to an ntfy topic. By default this is the public ntfy.sh server. You can self-host ntfy for full control.

**Who can see it:** Anyone who knows your topic name can subscribe to it. Choose a topic name that is long and random — treat it like a password. If you self-host ntfy, only you have access.

**Configuration:** Topic name and server URL are stored in `.secrets/ntfy.env` on your local machine. This file is never synced to Supabase or sent anywhere.

**How to disable:** Remove or empty `.secrets/ntfy.env`. Notifications will stop immediately. Alternatively, change your topic name — the old topic becomes unreachable.

---

## Ambient data capture

bOS passively captures data mentioned in natural conversation — for example, if you say "wydałem 50 zł na lunch," bOS logs that expense without you running `/expense`. Similarly, energy levels, task completions, sleep quality, and exercise are captured when mentioned.

**What gets captured:** Only structured data points — amounts, energy scores (1-10), task status changes, sleep hours. General conversation text is NOT stored.

**Where it goes:** The same state files as explicit skill commands — `state/finances.md`, `state/daily-log.md`, `state/tasks.md`. No new storage locations.

**How you know:** bOS confirms each capture at the end of its response — e.g., "Zapisałem: lunch 50 zł." You can correct or undo immediately.

**What it does NOT do:**
- Does NOT capture vague statements — only clear data points with numbers
- Does NOT log data from planning context ("I'll go to the gym tomorrow" ≠ logged workout)
- Does NOT store conversation text — only the extracted data point
- Does NOT capture greetings or pleasantries as data

## Data gap detection

Session start injects locators and facts. It does **not** ask about energy or offer `/review-week`. `/morning` and `/evening` run only if you ask.

---

## Session context injection (hooks)

bOS uses lifecycle hooks (SessionStart, PreCompact, Stop) that run automatically as shell scripts. These hooks:

- Read the current date and time from your local system clock
- Count pending tasks and overdue items from local state files
- Check your financial buffer status from `state/finances.md`
- Scan `state/context-bus.jsonl` for unexpired critical signals (TTL is a read filter)

**No external service is involved.** Hooks are plain shell scripts that run locally. They do not send data anywhere — they only read local files and inject a summary into your session context. The same privacy rules apply as for interactive bOS use: everything stays on your machine.

---

## Headless execution (`claude -p`)

`/schedule` is **not Lite**. Sample skill: `examples/skills/schedule/`. If you copy it in and run `claude -p` yourself, privacy is the same as an interactive session. Lite does not arm that cron.

---

## Relationship data (network.md)

If you use `/network`, bOS stores names, context (how you know someone), and follow-up dates in `state/network.md`. This is private — bOS never shares contact information outside the local system. No data from network.md is sent to external services (unless you configure a webhook for it).

---

## Journal entries (journal.md)

If you use `/reflect`, bOS stores your micro-journal entries (a question and your answer) in `state/journal.md`. These are private reflections. After 30+ entries, @coach may identify patterns during your weekly review — but this analysis stays local.

---

## Unified Inbox data

`/inbox` in Lite is Gmail/Outlook **MCP if you connected them** — not a multi-channel n8n inbox. It does not write full mail bodies to `state/`.

`/schedule` and `/marketplace` are **not Lite**. Samples: `examples/skills/schedule/`. There is no skill registry.

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

## Session handoff data

When you run `/wrap-up`, bOS saves a structured summary of the current session to `state/handoff.md`. This includes: what was done, what's in progress, decisions made, and suggested first action for next session. Handoff files are overwritten each time — only the latest matters. They expire after 3 days and are ignored by SessionStart hooks after that.

---

## Ambient task completion detection

bOS monitors your conversation for work that matches open tasks in `state/tasks.md`. When it detects a likely completion, it asks you to confirm before marking anything done. It never auto-marks tasks — the user always confirms via clickable options. No conversation text is stored — only the task status change in `state/tasks.md`.

---

## Email (optional, not wired)

`/inbox` can search Gmail/Outlook **if you connected those MCP servers**. Lite does **not** ship a live 15-minute email cron. Sample launchd files live in `examples/hooks/ntfy/` and stay off until you install them (they hard-fail without an ntfy topic).

Email bodies are not written to `state/`.

---

## Skill-run logs

Lite `/check` reports from **disk** (roster, files, hooks). It does not require `state/skill-runs.jsonl`. If that file appears, it is local telemetry — no conversation text.

---

## Plugins

Claude Code plugins you install yourself have their own policies. They are not part of this Lite folder.

---

## Questions?

bOS is an open system — you can read every file it creates. If you're ever unsure what's stored, just look in:
- `profile.md` — your profile
- `state/` — your activity data
- `.secrets/` — your secrets (open files in an editor; never paste into chat)
- `~/.claude/projects/<project>/memory/` — agent memory

Everything is readable text. Nothing is hidden.
