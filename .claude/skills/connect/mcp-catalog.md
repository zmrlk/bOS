# MCP Catalog — Vetted Connectors for bOS

> Last updated: 2026-03-03. Update during each /evolve or /bos-dev research cycle.
> Source: Anthropic MCP Registry, GitHub, community reviews.

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

## Community Servers (Vetted, Score >=8/10)

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
| **Business owner** | GitHub, Notion/Linear, Stripe, Slack | Core business stack |
| **Freelancer** | GitHub, Notion, Stripe, Gmail/ms365 | Client management |
| **Developer** | GitHub, Playwright, Sentry, Supabase, Context7 | Dev workflow |
| **Designer** | Figma, Canva, Miro | Creative tools |
| **Manager** | Slack, Asana/Linear, Notion, Google Calendar | Team coordination |
| **Student** | Notion, Google Drive, Context7 | Learning & notes |
| **Sales** | HubSpot, Slack, Gmail/ms365 | Pipeline management |
| **Marketing** | Canva, HubSpot, Slack | Content & campaigns |

---

## Security Checklist (for new/unknown MCPs)

Before installing ANY MCP not in this catalog:

- [ ] GitHub >=100 stars OR official Anthropic marketplace
- [ ] Last commit < 3 months (actively maintained)
- [ ] Positive reviews on >=2 sources (Reddit, GitHub, X)
- [ ] No sudo/root/admin required
- [ ] Open source (full code available)
- [ ] Clear permissions in README
- [ ] No security flags in GitHub issues
- [ ] Known author (GitHub history, not anonymous)

**Score >=8/10 = safe to propose. <8 = DO NOT install.**

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
