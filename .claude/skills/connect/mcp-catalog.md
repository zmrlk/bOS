# MCP Catalog — Vetted Connectors for bOS

> Last updated: 2026-03-03. Update during each /bos-dev research cycle.
> Source: Anthropic MCP Registry, GitHub, community reviews, mcp.so, glama.ai, pulsemcp.com, smithery.ai
> Ecosystem: ~18,000+ MCP servers (Glama: 18,052 | PulseMCP: 8,600+ | Smithery: 7,300+)

---

## How to Install MCPs

### Three methods (in order of preference)

| Method | Command | Best for | Notes |
|--------|---------|----------|-------|
| **Marketplace** | Toggle in Claude Desktop or claude.ai/settings/connectors | Non-technical users | One-click, auto-managed |
| **HTTP remote** | `claude mcp add --transport http [name] [url]` | Most servers | Recommended transport |
| **stdio local** | `claude mcp add --transport stdio [name] -- npx -y [package]` | Local tools, custom servers | Runs on your machine |

### Scopes

| Scope | Flag | Where stored | Use when |
|-------|------|-------------|----------|
| **local** | (default) | `~/.claude.json` | Personal, this project only |
| **project** | `--scope project` | `.mcp.json` (committed) | Shared with team |
| **user** | `--scope user` | `~/.claude.json` | Personal, all projects |

### After installing
- `/mcp` — authenticate (OAuth), check status, manage servers
- `claude mcp list` — see all configured servers
- `claude mcp get [name]` — check specific server
- `claude mcp remove [name]` — remove a server

### Import from Claude Desktop
```bash
claude mcp add-from-claude-desktop
```
Interactive dialog lets you pick which servers to import.

---

## Official Registry (Anthropic Marketplace)

These are verified by Anthropic and available via HTTP transport. Score: 10/10.

### Communication & Email

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Gmail** | Read, search, send email | Marketplace toggle (claude.ai/settings/connectors) |
| **Slack** | Messages, channels, search workspace | `claude mcp add --transport http slack https://mcp.slack.com/mcp` |
| **Intercom** | Customer data, conversations | `claude mcp add --transport http intercom https://mcp.intercom.com/mcp` |

### Productivity & Project Management

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Notion** | Search, create, update pages and databases | `claude mcp add --transport http notion https://mcp.notion.com/mcp` |
| **Asana** | Tasks, projects, goals coordination | `claude mcp add --transport http asana https://mcp.asana.com/v2/mcp` |
| **Linear** | Issues, projects, team workflows | `claude mcp add --transport http linear https://mcp.linear.app/mcp` |
| **monday.com** | Boards, projects, workflows | `claude mcp add --transport http monday https://mcp.monday.com/mcp` |
| **ClickUp** | Tasks, docs, project management | `claude mcp add --transport http clickup https://mcp.clickup.com/mcp` |
| **Atlassian** | Jira issues + Confluence docs | `claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp` |

### Design & Creative

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Figma** | Read designs, generate from context | `claude mcp add --transport http figma https://mcp.figma.com/mcp` |
| **Canva** | Create, edit, export designs | `claude mcp add --transport http canva https://mcp.canva.com/mcp` |
| **Miro** | Boards, diagrams, visual collaboration | `claude mcp add --transport http miro https://mcp.miro.com/` |
| **Gamma** | Presentations, docs, sites | `claude mcp add --transport http gamma https://mcp.gamma.app/mcp` |

### Development & DevOps

| Name | What it does | Install command |
|------|-------------|-----------------|
| **GitHub** | Repos, PRs, issues, CI/CD | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| **Sentry** | Error tracking, debugging | `claude mcp add --transport http sentry https://mcp.sentry.dev/mcp` |
| **Vercel** | Deployments, projects, analytics | `claude mcp add --transport http vercel https://mcp.vercel.com` |
| **Supabase** | Database, auth, storage, edge functions | `claude mcp add --transport http supabase https://mcp.supabase.com/mcp` |

### Payments & CRM

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Stripe** | Payments, invoices, subscriptions | `claude mcp add --transport http stripe https://mcp.stripe.com` |
| **HubSpot** | CRM, contacts, deals, marketing | `claude mcp add --transport http hubspot https://mcp.hubspot.com/mcp` |

### Data & Analytics

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Amplitude** | Product analytics, user insights | `claude mcp add --transport http amplitude https://mcp.amplitude.com/mcp` |

### Automation

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Zapier** | Automate workflows across 7000+ apps | `claude mcp add --transport http zapier [your-zapier-mcp-url]` |
| **n8n** | Self-hosted workflow automation | `claude mcp add --transport http n8n [your-n8n-instance-url]/mcp` |

### Knowledge & Research

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Context7** | Up-to-date library docs for coding | `claude mcp add --transport http context7 https://mcp.context7.com/mcp` |
| **Hugging Face** | ML models, datasets, Gradio apps | `claude mcp add --transport http hugging-face https://huggingface.co/mcp` |
| **PubMed** | Biomedical literature search | `claude mcp add --transport http pubmed https://mcp.pubmed.ncbi.nlm.nih.gov/mcp` |

### Meetings & Notes

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Granola** | Meeting notes and AI insights | `claude mcp add --transport http granola https://mcp.granola.ai/mcp` |
| **Fireflies** | Meeting transcripts and analysis | `claude mcp add --transport http fireflies https://mcp.fireflies.ai/mcp` |

### Storage

| Name | What it does | Install command |
|------|-------------|-----------------|
| **Box** | File storage, search, sharing | `claude mcp add --transport http box https://mcp.box.com/mcp` |

**Authentication:** Most marketplace servers use OAuth. After adding, run `/mcp` in Claude Code to authenticate via browser.

---

## Community Servers (Vetted, Score ≥8/10)

These are open-source, actively maintained, and community-verified.

### Microsoft 365 / Outlook (THE solution for business email)

| Option | Install command | Works with | Score |
|--------|----------------|------------|-------|
| **Softeria ms-365** (recommended) | `claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server` | Personal + Work accounts | 9/10 |
| **Softeria ms-365 (org mode)** | `claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --org-mode` | Work/School only | 9/10 |
| **XenoXilus outlook-mcp** | `claude mcp add outlook -- npx -y @xenoxilus/outlook-mcp` | Outlook + SharePoint | 8/10 |
| **Official M365 connector** | Marketplace (Team/Enterprise only) | Requires Global Admin | 10/10 |

**Softeria ms-365 features:** Email (read, send, draft, move, delete), Calendar (events, create, update), OneDrive (files, search), Contacts, Tasks, OneNote, Excel.

**Presets** (limit tools loaded):
```bash
# Only email
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --preset mail
# Email + calendar
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --preset mail --preset calendar
# Everything
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --preset all
```

**Authentication:** First run opens browser for Microsoft login. Uses Device Code Flow by default.

### Google Services

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **Google Calendar** | Marketplace toggle or `claude mcp add gcal -- npx -y @anthropic/google-calendar-mcp` | Events, scheduling | 10/10 |
| **Google Drive** | `claude mcp add gdrive -- npx -y @anthropic/google-drive-mcp` | Files, search, sharing | 9/10 |
| **Google Maps** | `claude mcp add gmaps -- npx -y @modelcontextprotocol/server-google-maps` | Location, directions, places | 9/10 |

### Database

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **PostgreSQL** | `claude mcp add postgres -- npx -y @modelcontextprotocol/server-postgres "postgresql://user:pass@host/db"` | SQL queries, schema | 9/10 |
| **SQLite** | `claude mcp add sqlite -- npx -y @modelcontextprotocol/server-sqlite [path.db]` | Local database | 9/10 |
| **MySQL** | `claude mcp add mysql -- npx -y @benborla29/mcp-server-mysql` | MySQL queries | 8/10 |

### Development

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **GitHub (stdio)** | `claude mcp add github -- npx -y @modelcontextprotocol/server-github` | Repos, PRs, issues (needs GITHUB_TOKEN) | 10/10 |
| **GitLab** | `claude mcp add gitlab -- npx -y @modelcontextprotocol/server-gitlab` | GitLab API | 9/10 |
| **Playwright** | `claude mcp add playwright -- npx -y @playwright/mcp@latest` | Browser automation, testing | 10/10 |
| **Docker** | `claude mcp add docker -- npx -y @modelcontextprotocol/server-docker` | Container management | 8/10 |

### System & Files

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **Desktop Commander** | Marketplace toggle | File system access, terminal | 10/10 |
| **Filesystem** | `claude mcp add fs -- npx -y @modelcontextprotocol/server-filesystem /path1 /path2` | Sandboxed file access | 9/10 |
| **Control your Mac** | Marketplace toggle | AppleScript, system commands | 9/10 |
| **iMessage** | Marketplace toggle | Read/send iMessages | 8/10 |

### Search & Web

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **Brave Search** | `claude mcp add brave -- npx -y @anthropic/brave-search-mcp --env BRAVE_API_KEY=YOUR_KEY` | Web + local search | 9/10 |
| **Fetch** | `claude mcp add fetch -- npx -y @modelcontextprotocol/server-fetch` | Fetch web content | 9/10 |

### AI & Knowledge

| Name | Install command | What it does | Score |
|------|----------------|-------------|-------|
| **Sequential Thinking** | `claude mcp add thinking -- npx -y @modelcontextprotocol/server-sequential-thinking` | Structured reasoning chains | 9/10 |
| **Memory (knowledge graph)** | `claude mcp add memory -- npx -y @modelcontextprotocol/server-memory` | Persistent memory via knowledge graph | 8/10 |

---

## Email Setup Guide (Special Section)

Email is the most requested connector. Here's how to connect each provider:

### Gmail
**Easiest:** Marketplace toggle in claude.ai/settings/connectors (one-click).
**CLI alternative:** Import from Claude Desktop if already configured there.

### Outlook / Microsoft 365
**For personal (Outlook.com, Hotmail, Live):**
```bash
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server
```

**For work/school (company Outlook):**
```bash
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --org-mode
```

**For Enterprise (Team/Enterprise Claude plan + Global Admin):**
Toggle in Marketplace → requires admin approval.

### WP Poczta / Yahoo / Other IMAP
```bash
claude mcp add email -- npx -y mcp-mail-manager
```
Requires IMAP credentials (server, port, username, password).

### Quick decision tree:
```
Email provider?
├── Gmail → Marketplace toggle (1 click)
├── Outlook/Hotmail → softeria ms-365 (npx)
├── Company Outlook → softeria ms-365 --org-mode (npx)
└── Other (WP, Yahoo, custom) → mcp-mail-manager (IMAP)
```

---

## Calendar Setup Guide

### Google Calendar
**Easiest:** Marketplace toggle in claude.ai/settings/connectors.
**CLI:** `claude mcp add gcal -- npx -y @anthropic/google-calendar-mcp`

### Outlook Calendar
Included in ms-365-mcp-server:
```bash
claude mcp add ms365 -- npx -y @softeria/ms-365-mcp-server --preset calendar
```

### Apple Calendar
No reliable MCP yet. Workaround: use Desktop Commander to read .ics files.

---

## What to Suggest by User Profile

| User profile | Recommended MCPs | Why |
|-------------|-----------------|-----|
| **Business owner** | GitHub, Notion/Linear, Stripe, Slack, WhatsApp, ntfy* | Core business + messaging |
| **Freelancer** | GitHub, Notion, Stripe, Gmail/ms365, WhatsApp, Clockwise | Client mgmt + focus time |
| **Developer** | GitHub, Playwright, Sentry, Supabase, Context7, Tavily | Dev workflow + research |
| **Designer** | Figma, Canva, Miro, YouTube | Creative tools + inspiration |
| **Manager** | Slack, Asana/Linear, Notion, Google Calendar, Clockwise | Team coord + scheduling |
| **Student** | Notion, Google Drive, Context7, YouTube, Spotify | Learning + focus music |
| **Sales** | HubSpot, Slack, Gmail/ms365, WhatsApp, Postiz | Pipeline + social selling |
| **Marketing** | Canva, HubSpot, Slack, Postiz, GA4, DeepL | Content + analytics |
| **ADHD** | Clockwise, Spotify, ntfy*, Apple Reminders | Focus defense + notifications |
| **Health-focused** | Open Wearables, Garmin, Spotify | Fitness tracking + motivation |

*ntfy = built into bos-compound-mcp, no separate install needed

---

## Messaging & Communication

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **WhatsApp** (Go) | `claude mcp add whatsapp -- npx -y whatsapp-mcp` | Personal WhatsApp — messages, contacts, search. SQLite local. | 9/10 | HIGH |
| **WhatsApp** (TS) | `claude mcp add whatsapp -- npx -y whatsapp-mcp-ts` | TypeScript alt — Baileys library | 8/10 | HIGH |
| **Telegram** | `claude mcp add telegram -- npx -y telegram-mcp` | Send/receive Telegram, manage chats | 6/10 | LOW |
| **Discord** | Community implementations | Channel messaging, server management | 5/10 | LOW |

**WhatsApp note:** QR code scan on first run. Messages stored locally in SQLite, only sent to LLM when accessed. Critical for @inbox unified messaging.

## Productivity & Focus (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Clockwise** | `claude mcp add --transport http clockwise https://www.getclockwise.com/mcp` | Smart scheduling, focus time defense, capacity analysis | 8/10 | HIGH |
| **FocusMo** (ADHD) | FocusMo Pro + MCP integration | Focus data, streaks, app usage for ADHD coaching | 9/10 | MED (paid) |
| **Apple Reminders** | `claude mcp add reminders -- npx -y apple-reminders-mcp` | Manage Reminders natively, sync to iPhone | 8/10 | MED |

**Clockwise:** Free tier exists. ADHD-critical: auto-defends 4-6h focus blocks/week.

## Media & Content (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Spotify** | `claude mcp add spotify -- npx -y spotify-mcp` | Playback control, playlists, search | 8/10 | MED |
| **YouTube** | `claude mcp add youtube -- npx -y mcp-youtube` | Video search, transcript extraction, trends | 8/10 | MED |
| **Postiz** (Social) | Self-hosted or cloud + MCP | Schedule posts to X, LinkedIn, IG, TikTok | 8/10 | MED |

**YouTube note:** Needs YouTube Data API v3 key. Token-optimized: smart transcript segmentation.
**Spotify note:** Needs Spotify Developer App + OAuth. @wellness focus music, @focus ADHD playlists.

## Translation (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **DeepL** | `claude mcp add deepl -- npx -y deepl-mcp-server` | Professional multilingual translation, document translation | 8/10 | MED |
| **Lara Translate** | `claude mcp add lara -- npx -y lara-mcp` | Context-aware translation with memory | 6/10 | LOW |

**DeepL:** Free tier: 500k chars/month. Great for proposals + @cmo content in multiple languages.

## Health & Fitness (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Open Wearables** | `claude mcp add wearables -- npx -y @openwearables/mcp-server` | Unified wearable data: Strava, Garmin, Apple Health, Polar, Whoop | 8/10 | LOW |
| **Garmin Connect** | `claude mcp add garmin -- npx -y garmin-connect-mcp` | Garmin workout data, health metrics | 7/10 | LOW |
| **Spike Health** | Spike API account + MCP | Wearable + fitness aggregation | 7/10 | LOW |

**Open Wearables:** 47 sports science tools. v0.3.0-alpha (Jan 2026). @trainer + @wellness.

## Research & Deep Web (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Tavily** | `claude mcp add tavily -- npx -y tavily-mcp` | AI-optimized search + extract + research | 9/10 | HIGH (needs key) |
| **Firecrawl** | `claude mcp add firecrawl -- npx -y firecrawl-mcp` | Web scraping, crawling, structured extraction | 9/10 | HIGH (needs key) |
| **Exa AI** | `claude mcp add exa -- npx -y exa-mcp` | Semantic search, find similar | 8/10 | MED (needs key) |
| **Brave Search** | `claude mcp add brave -- npx -y @anthropic/brave-search-mcp --env BRAVE_API_KEY=KEY` | Web + local search | 9/10 | MED (needs key) |

**Note:** All require API keys.

## Memory & Knowledge (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Mem0/OpenMemory** | `pip install mcp-mem0` or OpenMemory local | Semantic memory search, graph memory | 8/10 | MED |
| **Knowledge Graph** | `claude mcp add kg -- npx -y mcp-knowledge-graph` | Entity-relation graph, persistent context | 7/10 | LOW |

**Mem0:** 9k+ GitHub stars. bOS already has memory architecture, but Mem0 adds semantic search. Candidate for bOS 1.0 Concept Graph.

## Analytics & SEO (NEW)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Google Analytics GA4** | `claude mcp add ga4 -- npx -y google-analytics-mcp` | 200+ dimensions, traffic, conversions | 8/10 | MED |
| **DataForSEO** | DataForSEO API key + MCP | SERP, keywords, backlinks | 7/10 | LOW (paid) |

## MCP Gateways (Mega-tools)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Composio** | `claude mcp add --transport http composio https://mcp.composio.dev/` | ONE gateway to 300+ apps, managed OAuth | 9/10 | FUTURE |
| **Zapier MCP** | `claude mcp add --transport http zapier [your-zapier-url]` | ONE connection to 8,000+ apps | 8/10 | FUTURE |

**Privacy note:** Data flows through gateway provider. For sensitive data, prefer individual local MCPs. Good for non-sensitive ops when MCP count gets unwieldy.

## Smart Home (Future — bOS 2.0)

| Name | Install command | What it does | Score | Priority |
|------|----------------|-------------|-------|----------|
| **Home Assistant** | `claude mcp add ha -- [HA instance]/mcp` | Smart home control, automations | 7/10 | bOS 2.0 |

---

## Ecosystem Gaps (No good MCP exists yet)

1. **EU/Regional banking** — No PSD2-compliant open banking MCP for most EU countries. Plaid is US/UK focused.
2. **Regional invoicing systems** — Country-specific invoicing tools lack MCP integration.
3. **ADHD-specific productivity** — FocusMo is paywalled. Opportunity for open-source.
4. **Personal energy tracking** — No dedicated MCP (bOS has this internally via /energy-map).
5. **Smart Pomodoro** — Flowtime/adaptive focus MCP doesn't exist.

---

## Security Checklist (for new/unknown MCPs)

Before installing ANY MCP not in this catalog:

- [ ] GitHub ≥100 stars OR official Anthropic marketplace
- [ ] Last commit < 3 months (actively maintained)
- [ ] Positive reviews on ≥2 sources (Reddit, GitHub, X)
- [ ] No sudo/root/admin required
- [ ] Open source (full code available)
- [ ] Clear permissions in README
- [ ] No security flags in GitHub issues
- [ ] Known author (GitHub history, not anonymous)

**Score ≥8/10 = safe to propose. <8 = DO NOT install.**

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Connection closed" after install | Restart Claude Code session |
| OAuth login doesn't open browser | Copy URL manually from terminal |
| "Incompatible auth server" error | Need pre-configured OAuth credentials (see docs) |
| MCP timeout on startup | Set `MCP_TIMEOUT=10000 claude` for slower servers |
| Output too large warning | Set `MAX_MCP_OUTPUT_TOKENS=50000` |
| Server works in Desktop, not CLI | Run `claude mcp add-from-claude-desktop` |
| Windows npx fails | Use `cmd /c` wrapper: `-- cmd /c npx -y [package]` |
