---
name: connect
description: "Manage MCP connections — add, remove, test, discover connectors. Use when the user wants to connect a tool, check connections, or find new integrations."
user_invocable: true
argument-hint: "[service-name | list | test | discover]"
---

# bOS — Connect (MCP Manager)

One skill to manage all your connections. Add tools, test connections, discover new ones.

**Reference:** See [mcp-catalog.md](mcp-catalog.md) for the full vetted MCP catalog with installation commands.

---

## Modes

| Command | What it does |
|---------|-------------|
| `/connect` | Show current connections + quick actions |
| `/connect [service]` | Connect a specific service (gmail, outlook, notion, figma, etc.) |
| `/connect list` | Show all available connectors from catalog |
| `/connect test` | Test all current connections |
| `/connect discover` | Search internet for new MCPs matching your profile |
| `/connect remove [name]` | Remove a connector |
| `/connect import` | Import servers from Claude Desktop |

---

## Protocol

### Step 0: Read Context

1. Read `profile.md` → `connected_mcps`, `tech_comfort`, `active_packs`, `user_type`
2. Read [mcp-catalog.md](mcp-catalog.md) for reference

---

### MODE: `/connect` (status overview)

Show current connection status, adapted to `tech_comfort`:

**"not technical":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Your connections
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Files & Desktop
  ✅ Web browser
  ✅ Calendar
  ✅ Email (Gmail)
  ❌ Cloud notes
  ❌ Design tools

  [X] active, [Y] available to add
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**"I use apps":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Connections (superpowers)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Desktop Commander
  ✅ Web Search/Fetch
  ✅ Google Calendar
  ✅ Gmail
  ✅ Figma
  ✅ Canva
  ❌ Notion
  ❌ Slack

  [X]/[Y] active
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**"I code":**
```
  MCP connectors:
  ✅ Desktop Commander     ✅ Gmail
  ✅ Web Search/Fetch      ✅ Figma
  ✅ Google Calendar        ✅ Canva
  ✅ n8n                    ✅ GitHub
  ❌ Notion                 ❌ Slack

  [X] active | claude mcp list for details
```

Then offer quick actions via `AskUserQuestion`:
- "Add a connection" → go to /connect list
- "Test all connections" → go to /connect test
- "Search for new tools" → go to /connect discover
- "All good" → done

---

### MODE: `/connect [service]` (connect specific service)

**Step 1: Match service name to catalog**

Match user's input (fuzzy) to entries in mcp-catalog.md:
- "gmail" / "email" / "poczta" → Email section
- "outlook" / "365" / "microsoft" / "firmowy mail" → Microsoft 365 section
- "notion" / "notatki" → Notion
- "figma" / "design" → Figma
- "canva" / "grafika" → Canva
- "slack" → Slack
- "github" / "git" → GitHub
- "calendar" / "kalendarz" → Calendar section
- "supabase" / "baza danych" / "database" → Supabase
- "stripe" / "platnosci" / "payments" → Stripe
- (etc. — match against catalog names, also in user's language)

If no match → "I don't have [X] in my catalog. Want me to search the internet for it?" → /connect discover [X]

**Step 2: Present installation**

Adapt presentation to `tech_comfort`:

**"not technical":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Connecting [Service Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  What this gives you:
  → [1-2 sentence benefit in simple terms]

  How: [method — marketplace click OR
  I'll install it for you automatically]

  Security: ✅ verified, open source
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Then: "Ready to connect?" → Yes/No

**"I use apps":**
```
  Connecting [Service Name]

  Benefit: [1 sentence]
  Method: [marketplace toggle / npm install / HTTP remote]
  Security: ✅ score [X]/10
  Price: Free / [cost]

  Ready to connect?
```

**"I code":**
```
  [Service Name]
  Install: [exact command from catalog]
  Transport: [http/stdio]
  Auth: [OAuth / API key / none]
  Score: [X]/10
```

Show exact command, let user confirm.

**Step 3: Install**

Execute the installation:
1. If marketplace → guide user to claude.ai/settings/connectors (one-click)
2. If CLI command → run `claude mcp add ...` (show command, execute)
3. After install → run `/mcp` if OAuth needed
4. Test connection with a simple call
5. Report result: ✅ connected or ❌ failed + troubleshooting

**Step 4: Update profile**

After successful connection:
1. Update `profile.md → Connected MCPs` — add new connector
2. Confirm: "✅ [Service] connected! I can now [benefit]."

---

### MODE: `/connect list` (catalog browser)

Show available connectors from mcp-catalog.md, grouped by category.

Adapt to user profile — highlight most relevant based on `active_packs` and `user_type`:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Available connections
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  RECOMMENDED FOR YOU:
  ⭐ [Service] — [why, based on profile]
  ⭐ [Service] — [why]
  ⭐ [Service] — [why]

  ALL CATEGORIES:
  📧 Communication: Gmail, Outlook, Slack
  📋 Productivity: Notion, Asana, Linear, monday
  🎨 Design: Figma, Canva, Miro
  💻 Development: GitHub, Sentry, Vercel
  💰 Payments: Stripe, HubSpot
  📊 Data: Supabase, PostgreSQL, Amplitude
  🔧 Automation: Zapier, n8n
  🔍 Knowledge: Context7, Hugging Face

  Say /connect [name] to add any of these.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Use the "What to Suggest by User Profile" table from mcp-catalog.md for recommendations.

---

### MODE: `/connect test` (health check)

Test each connected MCP with a simple call:

| MCP | Test method |
|-----|------------|
| Desktop Commander | `ls ~/Desktop` |
| Google Calendar | List today's events |
| Gmail | List recent emails |
| Supabase | `SELECT 1` |
| GitHub | List repos |
| Figma | List recent files |
| Notion | List pages |
| Slack | List channels |
| n8n | List workflows |
| Others | Appropriate test per MCP type |

Report:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Connection health
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ Desktop Commander — OK
  ✅ Gmail — OK (15 unread)
  ✅ Google Calendar — OK (3 events today)
  ⚠️ n8n — slow response (2.3s)
  ❌ Figma — connection failed

  [X]/[Y] healthy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

If any ❌ → offer to reconnect or troubleshoot.

---

### MODE: `/connect discover` (internet search)

**This is for finding MCPs NOT in the catalog.** Uses internet research.

**Step 1: Determine what to search for**

Based on profile:
- Tools detected in scan without MCP → "[tool] MCP server Claude [year]"
- User's packs with gaps → "Claude MCP [domain]"
- User's request → "[specific tool] MCP server"

**Step 2: Search**

```
Searching for [tool] integrations...
```

Batch WebSearch queries:
- "[tool] MCP server Claude Code [current year]"
- "[tool] MCP server Claude reddit"
- WebFetch mcp.so, glama.ai/mcp for latest listings

**Step 3: Security filter**

Every result MUST pass the 8-point security checklist from mcp-catalog.md.
Score <8 → reject silently. Score ≥8 → present to user.

**Step 4: Present findings (max 3)**

Adapted to tech_comfort (same format as /connect list recommendations).

**Step 5: Install if approved**

Same flow as /connect [service] Step 3-4.

**Step 6: Update catalog**

If a new vetted MCP is found → suggest adding it to mcp-catalog.md for future reference.

---

### MODE: `/connect remove [name]`

1. Find the server by name (fuzzy match)
2. Confirm: "Remove [name]? You'll lose access to [what it provides]."
3. Execute: `claude mcp remove [name]`
4. Update `profile.md → Connected MCPs`
5. Confirm: "✅ [name] removed."

---

### MODE: `/connect import`

Import servers from Claude Desktop:

```
⏳ Checking Claude Desktop configuration...
```

1. Run `claude mcp add-from-claude-desktop`
2. Show interactive selection
3. After import → test each imported server
4. Update `profile.md → Connected MCPs`

---

## Special Flows

### Email Setup (most common request)

When user says anything about email/poczta/mail:

```
Which email do you use?
```

`AskUserQuestion`:
- "Gmail" → Marketplace toggle (1 click)
- "Outlook / Hotmail" → `npx -y @softeria/ms-365-mcp-server`
- "Company Outlook (work)" → `npx -y @softeria/ms-365-mcp-server --org-mode`
- "Other (WP, Yahoo, etc.)" → `npx -y mcp-mail-manager` (IMAP)

Walk through the specific flow for their choice.

### Calendar Setup

`AskUserQuestion`:
- "Google Calendar" → Marketplace toggle
- "Outlook Calendar" → ms-365-mcp-server --preset calendar
- "Apple Calendar" → "No reliable MCP yet. I'll note it for future."

---

## Rules

1. **Catalog first, internet second.** Check mcp-catalog.md before searching the internet.
2. **Never install without confirmation.** Always show what you're about to install and ask.
3. **Adapt to tech_comfort.** Hide "MCP" from non-technical users. Use "connection" or "extension."
4. **Test after install.** Every new connection gets a test call.
5. **Update profile.** Always update `profile.md → Connected MCPs` after changes.
6. **Security non-negotiable.** Score <8 = don't install, no exceptions.
7. **Show price.** If an MCP requires a paid service → show the cost before installing.
8. **Troubleshoot gracefully.** If install fails → check mcp-catalog.md troubleshooting section, offer alternatives.
