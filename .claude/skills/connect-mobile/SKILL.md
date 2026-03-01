---
name: Connect Mobile
description: "Set up phone access to bOS — via Remote Control (native, simple) or Telegram (advanced, works independently). Adapted to tech comfort."
user_invocable: true
command: /connect-mobile
---

# bOS — Connect Mobile

## Overview

Two ways to use bOS from your phone:

| | Remote Control | Telegram |
|--|---------------|----------|
| **Setup** | 1 minute | ~15 minutes |
| **How** | Scan QR code | Create bot + n8n + Supabase |
| **Requires** | Computer running Claude Code | n8n account ($20/mo or self-hosted) |
| **Works when** | Computer is on, session open | Independently (24/7) |
| **Full power** | Yes — full local access | Limited to configured commands |
| **Best for** | Quick access, deep work on the go | Automated briefings, always-on bot |

The entire flow adapts to `tech_comfort` from profile.md.

**Key principle:** bOS DOES, not just INSTRUCTS. Before telling the user "go to this website", bOS checks: can I look this up myself? Can I generate this? Can I verify this? If yes → do it, show the result, explain.

---

## Prerequisites — Check First

**FIRST: Verify profile.md exists.**
If profile.md doesn't exist or is empty → "You need to set up bOS first. Say /setup."
Do NOT proceed with mobile setup without a profile.

Before starting, read `profile.md` and check:

1. **tech_comfort** — determines how to explain everything
2. **system_mode** — if already "pro" (Supabase connected), skip Supabase setup in Telegram path
3. **mobile_connected** — if already "yes", show current status instead of setup

If `mobile_connected = yes`:
Show current connection status (which method is active, available commands). Ask if they want to add the other method or need help.

---

## Step 0 — Choose Method

**Default = Remote Control** (simplest, 1 minute, full power). Telegram is for advanced users who need 24/7 access.

**Show costs upfront for Telegram:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Phone Access Options
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Remote Control — FREE, 1 min setup
     Scan QR code, full bOS access.
     Computer must be on.

  2. Lite Mobile — FREE, 0 min setup
     Open claude.ai on your phone browser.
     No file access, but basic chat works.

  3. Telegram Bot — $25-35/mo extra
     Always-on bot, works 24/7.
     Requires n8n + Claude API key.
     ~15 min setup.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- header: "Mobile access"
- question: "How do you want to use bOS from your phone?"
- options:
  - "Remote Control (Recommended)" (description: "Scan a QR code, use bOS instantly. Free, 1 min. Computer must be on.")
  - "Lite Mobile — just bookmark claude.ai" (description: "Free, zero setup. Open claude.ai on phone. No files, but chat with agents works.")
  - "Telegram Bot ($25-35/mo)" (description: "Always-on 24/7 bot. Requires n8n + Supabase + Claude API. ~15 min setup.")
  - "Not now" (description: "Come back anytime with /connect-mobile.")

**If "Not now":** "No problem. Say /connect-mobile whenever you're ready." → END

**If "Lite Mobile":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Lite Mobile — Done!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Open claude.ai on your phone browser
  and bookmark it. That's it.

  What works:
  ✅ Chat with any agent
  ✅ Ask questions, get advice
  ✅ Morning briefing (manual)

  What doesn't:
  ❌ No local file access
  ❌ No MCP connections
  ❌ No automated reminders

  Upgrade to Remote Control anytime
  for full access: /connect-mobile
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
Update profile.md: `mobile_connected = lite`. → END

**If "Remote Control":** → Go to OPTION A below.
**If "Telegram Bot":** → Skip to OPTION B (Telegram Setup) below.

---

## OPTION A — Remote Control (Native)

### A1. Explain

Adapt to tech_comfort:

**Not technical:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Remote Control
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  This lets you control bOS from your
  phone — like a remote for your computer.

  Your phone connects to Claude Code
  running on your computer. You get full
  power — everything works, just from
  your phone screen.

  One catch: your computer needs to be
  on with Claude Code open.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**I use apps:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Remote Control
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Your phone connects directly to Claude
  Code on your computer via claude.ai.

  Full access — files, agents, MCPs,
  everything. Computer must stay on.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**I code:**
```
  📱  Remote Control

  claude remote-control → QR code → scan
  → claude.ai/code or Claude mobile app.

  Full local env access. HTTPS polling,
  no inbound ports. Computer must stay on.
```

### A2. Start Session

Guide the user:

1. Tell them to run `claude remote-control` in their terminal (or explain that you can't run it for them — it starts an interactive session)
2. A QR code and URL appear in the terminal
3. User scans the QR with their phone camera → opens in Claude app or claude.ai/code
4. Done — they can now type on their phone and bOS responds with full local access

**Requirements to mention:**
- Claude Max plan required (Pro support coming soon)
- Must be logged in (`/login` in Claude Code if needed)
- Computer must stay on with the terminal open

### A3. Verify

```
Did it work? You should see the bOS conversation
on your phone screen.
```

Use `AskUserQuestion`:
- header: "Remote Control"
- question: "Is Remote Control working?"
- options:
  - "Yes, it works!" (description: "I can see bOS on my phone")
  - "I don't have a Max plan" (description: "Remote Control requires Claude Max")
  - "Something went wrong" (description: "I'll describe what happened")

**If "Yes, it works!":**
1. Update `profile.md`: `mobile_connected = yes`, `mobile_platform = remote-control`
2. Show:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Remote Control — connected! ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  To use bOS from your phone:
  1. Open terminal on your computer
  2. Run: claude remote-control
  3. Scan the QR code with your phone
  4. Talk to bOS from your phone

  Everything works — all agents, all
  skills, all your files and tools.

  Tip: tomorrow morning, start a remote
  session and say "m" for your briefing.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If user chose "Both":** After Remote Control is confirmed → "Remote Control is set up. Want to set up Telegram too (for 24/7 access)?" → If yes, continue to OPTION B.

**If "I don't have a Max plan":**
"Remote Control requires Claude Max ($100/mo). If you'd like phone access now, we can set up Telegram instead — it works with any Claude plan."
→ Offer to continue with Telegram (OPTION B) or wait.

**If "Something went wrong":**
- Ask what they see. Common issues:
  - Not logged in → run `/login` in Claude Code
  - QR doesn't scan → copy the URL and open in phone browser
  - Session doesn't connect → check internet on both devices
  - "Not available" error → check plan (needs Max)

---

## OPTION B — Telegram Setup

### Step 0B — Explain Requirements (adapted to tech_comfort)

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Phone Access (Telegram Bot)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  To use bOS from your phone, you need
  4 things:

  1. 📱 Telegram — free messaging app
     (like WhatsApp)

  2. ⚡ n8n — connects Telegram to bOS
     ($20/mo or free self-hosted)

  3. 🗄️ Supabase — stores your data
     (free account is enough)

  4. 🔑 Claude API key — so the bot
     can think (uses your subscription)

  I'll walk you through step by step.
  Each step takes 2-3 minutes.
  Total: ~15 minutes.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I use apps:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Mobile Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Mobile stack:
  1. Telegram — interface (free)
  2. n8n — automation, like Zapier ($20/mo)
  3. Supabase — database (free)
  4. Claude API key — the bot's brain

  No coding. ~15 min setup.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Mobile Stack
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Architecture:
  Phone → Telegram Bot API → n8n webhook
  → Supabase (shared state) → Claude API
  → response back through the chain

  Requirements:
  - Telegram bot (BotFather)
  - n8n Cloud ($20/mo) or self-hosted
  - Supabase project (free tier)
  - Claude API key

  ~10 min if you know these tools.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- header: "Ready?"
- question: "Ready to set up Telegram?"
- options:
  - "Yes, let's go" (description: "Start the 6-step setup")
  - "How much does it cost?" (description: "Show me the monthly costs")
  - "Maybe later" (description: "Come back to this anytime")

**If "How much does it cost?":**
bOS ITSELF checks current pricing (via web search/fetch) and presents verified info:
```
⏳ Checking current pricing...

  Monthly costs:
  - Telegram: free
  - n8n Cloud: [verified price] (or $0 self-hosted)
  - Supabase: free (free tier)
  - Claude API: depends on usage (~$5-15/mo)
  → Source: verified just now from service websites

  Total: ~$25-35/mo (or ~$5-15 self-hosted)
```

**If "Maybe later":** "No problem. Say /connect-mobile whenever you want." → END

---

## Step 1/6 — Telegram Bot Setup

### Save progress before starting:
Write to `state/.mobile-setup-progress.md`:
```
step: 1
started: [ISO timestamp]
```

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 1/6 — Telegram Bot
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  1. Install Telegram on your phone
     (App Store or Google Play)

  2. Create an account (phone number)

  3. In Telegram, search for: @BotFather

  4. Send him: /newbot

  5. Name your bot (e.g., "My bOS")

  6. Choose a username (e.g., mybos_bot)

  7. BotFather will give you a TOKEN
     — copy it (looks like: 123456:ABC-DEF...)

  ⚠️  Save the token — you'll need it
      in step 5.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
  Step 1/6 — Telegram Bot

  @BotFather → /newbot → save token.
  You know the drill.
```

Use `AskUserQuestion`:
- header: "Step 1"
- question: "Do you have the Telegram bot token?"
- options:
  - "Done — I have the token" (description: "BotFather gave me the token")
  - "I'm stuck" (description: "I need more help")
  - "Skip — I already have a bot" (description: "I'll reuse an existing bot")

**If "I'm stuck":** Show more detailed walkthrough with screenshots-like descriptions. Ask what exactly is the problem.

---

## Step 2/6 — n8n Account

Update progress: `step: 2`

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 2/6 — n8n (automation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  n8n is a tool that connects apps
  together — like an automatic messenger.

  It will relay messages from Telegram
  to bOS and back.

  1. Open: https://n8n.io
  2. Click "Get started free"
  3. Create an account (email + password)
  4. Choose Starter plan ($20/mo)
     or Community (free, self-hosted)

  After logging in you'll see an empty
  "workflows" page — that's correct.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
  Step 2/6 — n8n

  n8n.io → Starter plan ($20/mo)
  or self-host: docker run n8nio/n8n

  Need a running n8n instance with
  webhook access.
```

Use `AskUserQuestion`:
- header: "Step 2"
- question: "Do you have an n8n account?"
- options:
  - "Done — I have an n8n account" (description: "I'm logged into n8n")
  - "I'm stuck" (description: "I need more help")
  - "Skip — I already have n8n" (description: "I have n8n set up already")

---

## Step 3/6 — Supabase

Update progress: `step: 3`

**If system_mode is already "pro" (Supabase connected):** Skip this step entirely. Show: "Supabase already connected ✅ — skipping this step."

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 3/6 — Supabase (database)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Supabase stores your bOS data in the
  cloud — so your phone and computer
  see the same things.

  1. Open: https://supabase.com
  2. Click "Start your project"
  3. Sign in with GitHub or email
  4. Create a new project:
     - Name: "bOS" (or whatever you like)
     - Password: choose a strong one
     - Region: closest to you
  5. Wait ~2 minutes for setup

  Done — Supabase is free for our needs.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
  Step 3/6 — Supabase

  supabase.com → new project → your region.
  Free tier is fine.
  Save project URL and anon key.
```

Use `AskUserQuestion`:
- header: "Step 3"
- question: "Do you have a Supabase project?"
- options:
  - "Done — I have a Supabase project" (description: "Project is created")
  - "I'm stuck" (description: "I need more help")
  - "Skip — I already have Supabase" (description: "I have Supabase set up already")

---

## Step 4/6 — Import n8n Workflow Templates

Update progress: `step: 4`

**bOS generates the templates ITSELF — the user just imports them.**

### 4A. Check n8n version (before generating)

```
⏳ Checking n8n version...
```

Use `AskUserQuestion`:
- header: "n8n version"
- question: "What version of n8n are you running? (In n8n: Settings → About)"
- options:
  - "1.x (latest)" (description: "You installed n8n recently")
  - "0.x (older)" (description: "You've had n8n for a while")
  - "I don't know" (description: "I'll check for you or generate a universal template")

If "I don't know" → generate for 1.x (safest, most common). Note: "Generating for the latest version. If there's a problem — we'll fix it."

### 4B. Template Generation Rules (CRITICAL — compatibility)

n8n changes node properties between versions. Templates MUST follow these rules:

1. **Minimal nodes** — use ONLY proven, stable ones:
   - ✅ Webhook, HTTP Request, IF, Set, Respond to Webhook, Schedule Trigger
   - ❌ NEVER: Telegram Trigger (version-dependent), Code node with exotic options
   - Use Webhook instead of Telegram Trigger (universal, works with every version)

2. **No optional "options" in nodes** — don't set optional properties:
   - Each node has ONLY required fields
   - Options like "authentication", "responseFormat", "batching" → skip
   - User can add manually if needed

3. **Schema v2 format** — n8n 1.0+ uses new workflow format:
   - Always generate with `"meta": { "templateCredsSetupCompleted": false }`
   - `"pinData": {}`
   - `"versionId"` = UUID v4

4. **Credentials as placeholder** — do NOT insert real credentials:
   - `"credentials": { "telegramApi": { "id": "REPLACE_ME", "name": "Telegram" } }`

5. **Mental test** — will this JSON work on a clean n8n 1.x without any extra packages?

6. **Fallback plan** — if import fails:
   - Show step-by-step manual workflow creation (screenshot-like descriptions)
   - "Don't worry — let's build it together step by step"
   - For tech users: show curl to n8n API (`POST /api/v1/workflows`)

### 4C. Generate templates

bOS generates the n8n workflow JSON files and saves them locally:

```
⏳ Generating workflow templates...
  📄 bos-telegram-router.json .... ✅
  📄 bos-morning-evening.json .... ✅
  📄 bos-expense-tracker.json .... ✅
  📄 bos-task-manager.json ....... ✅

  Saved templates to: state/n8n-templates/
```

**Templates generated based on active packs:**
- **Core (always):** Telegram command router → routes /morning, /evening, /status, /tasks, /done, /expense
- **Business pack:** Pipeline check, follow-up reminders
- **Health pack:** Workout logging, habit tracking
- **Life pack:** Task management, brain dumps

### 4D. Guide the import

The only part the user must do — bOS can't log into their n8n:

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 4/6 — Import templates
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  I generated ready-made templates.
  Now you'll import them into n8n:

  1. In n8n, click "Add workflow"
  2. Click "Import from file"
  3. Select the file from:
     state/n8n-templates/

  Start with: bos-telegram-router.json
  (this is the main template — rest is optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
  Step 4/6 — n8n Workflows

  Generated workflow JSONs in state/n8n-templates/.
  Import via n8n UI or POST /api/v1/workflows.
  Start with bos-telegram-router.json.
```

Use `AskUserQuestion`:
- header: "Step 4"
- question: "Did the import work?"
- options:
  - "Done — imported successfully" (description: "Workflow appeared in n8n")
  - "Import error" (description: "Import failed, I got an error")
  - "I'm stuck" (description: "I don't know what to do")
  - "Show instructions again"

### 4E. Import Error Fallback

**If "Import error":**

1. Ask for the error message:
   - "What error do you see? Copy the message or describe it."

2. Common errors and fixes:
   - **"Could not find property option"** → node property incompatible with user's n8n version
     - Fix: regenerate template with simpler nodes (Webhook instead of Telegram Trigger, remove all optional properties)
   - **"Invalid JSON"** → file corrupted or incomplete
     - Fix: regenerate the specific template
   - **"Unknown node type"** → node not available in user's n8n plan
     - Fix: replace with universal alternatives (HTTP Request instead of specific integrations)

3. If regeneration doesn't help → manual workflow creation:

   **Not technical:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     Don't worry — let's build it together
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

     We'll create the workflow manually,
     step by step:

     1. In n8n, click "Add workflow"
     2. Click "+" to add the first node
     3. Search for "Webhook" and add it
     4. In Webhook, set Method: POST
     5. Copy the Webhook URL — this is the
        address Telegram sends messages to

     Tell me what you see — I'll guide you.
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ```

   **I code:**
   ```
     Manual setup: n8n UI or API.

     curl -X POST https://your-n8n.com/api/v1/workflows \
       -H "X-N8N-API-KEY: $N8N_API_KEY" \
       -H "Content-Type: application/json" \
       -d @bos-telegram-router.json

     Or build manually: Webhook → Set → HTTP Request → Respond to Webhook.
   ```

4. Use `AskUserQuestion`:
   - header: "Import"
   - question: "Did the import work now?"
   - options:
     - "It works now!" (description: "Workflow imported successfully")
     - "Still broken — I'll describe" (description: "I'll share more details")
     - "Let's build manually" (description: "Walk me through it step by step")

---

## Step 5/6 — Configure API Keys

Update progress: `step: 5`

### Not technical:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 5/6 — Connecting the keys
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Now we connect everything together.
  You need 3 keys:

  1. BOT TOKEN (from step 1)
     → paste in n8n in the "Telegram Bot Token" field

  2. CLAUDE API KEY
     → Open: https://console.anthropic.com
     → Settings → API Keys → Create Key
     → Copy and paste in n8n

  3. SUPABASE CREDENTIALS (from step 3)
     → Project URL + anon key
     → Find in: Settings → API
     → Paste in n8n

  In n8n, open each workflow
  and fill in the credentials fields.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### I code:
```
  Step 5/6 — Credentials

  In n8n, configure these credentials:
  - Telegram Bot: paste bot token
  - Claude API: console.anthropic.com → API Keys
  - Supabase: project URL + anon key (Settings → API)

  Set as credentials in n8n, reference in workflows.
```

Use `AskUserQuestion`:
- header: "Step 5"
- question: "Are all keys connected in n8n?"
- options:
  - "Done — keys connected" (description: "All credentials are set up in n8n")
  - "I'm stuck" (description: "I need more help")
  - "Where do I find the Claude API key?" (description: "Show me how to get it")

---

## Step 6/6 — Test

Update progress: `step: 6`

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Step 6/6 — Test!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Open Telegram on your phone and send
  to your bot:

  /status

  If it replies — everything works! 🎉

  If it doesn't respond — check:
  1. Are workflows in n8n set to ACTIVE
     (green toggle)
  2. Is the bot token correct
  3. Is the Claude API key active
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use `AskUserQuestion`:
- header: "Test"
- question: "Does the bot respond?"
- options:
  - "It works! 🎉" (description: "Bot replied to /status")
  - "No response" (description: "Bot doesn't reply")
  - "Error — I'll describe" (description: "I got an error message")

**If "It works!":**
1. Update `profile.md`: `mobile_connected = yes`, `mobile_platform = telegram`
2. Delete `state/.mobile-setup-progress.md`
3. Show available Telegram commands:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱  Mobile — connected! ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Commands on your phone:

  /morning     morning briefing
  /evening     evening shutdown
  /expense     log an expense
  /status      quick status
  /tasks       today's tasks
  /done [id]   complete a task

  Or just type what you want
  — the bot understands.

  Tip: tomorrow morning, send /morning
  from your phone. 📱
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If "No response":** Troubleshoot step by step. Check n8n workflow status, credentials, webhook URLs.

---

## Crash Recovery

On `/connect-mobile` start, check if `state/.mobile-setup-progress.md` exists:
- If YES → read step number and offer to resume:
  - "Last time you were on step [X]/6. Continue from there?"
  - Options: "Continue" / "Start over"
- If NO → start fresh

---

## Rules

1. **Do it yourself first** — if bOS can do something (check a website, generate a template, verify a connection, look up docs), it DOES it. Only ask the user to act when it requires their account login or physical action.
2. **Every step has "I'm stuck" escape** — shows more detailed instructions. When user is stuck, bOS tries to diagnose the problem itself (check docs, search for solutions) before asking the user to debug.
3. **Not technical users get:** "Open this page, click this button..." style instructions.
4. **Technical users get:** config values and endpoints, skip explanations.
5. **Always optional** — "You can come back to this anytime."
6. **Never store API keys in bOS files** — guide user to enter them directly in n8n.
7. **After completion** — update profile.md with mobile status (platform: remote-control / telegram / both).
8. **Privacy note:** For Telegram, mention that messages go through Telegram servers. For Remote Control, mention data stays local. Link to PRIVACY.md for full data flow explanation.
9. **Verify after each step** — where possible, bOS checks if the step was successful (e.g., test webhook, ping bot). Don't just trust the user's "done" — verify and confirm.
10. **Recommend Remote Control first** — it's simpler, native, and keeps data local. Telegram is for users who need 24/7 access or don't have a Max plan.
