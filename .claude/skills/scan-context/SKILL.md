---
name: Scan Context
description: "Scan the user's files, calendar, and apps to build context about them. Used during setup or anytime the user wants bOS to learn more about them. Always requires explicit consent."
user_invocable: true
command: /scan
context: fork
---

# Context Scanner

**Adapt to tech_comfort:** "not technical" → "Chcę rzucić okiem na Twój komputer żeby Cię lepiej poznać. Sprawdzę nazwy folderów — nie otwieram plików." "I code" → "Glob scan of ~/Desktop, ~/Documents, ~/Downloads, /Applications — names only."

## Important
- ALWAYS ask for consent before scanning
- NEVER read file contents — only names and structure
- NEVER modify any files
- Inform user about token usage before starting

## Protocol

### Step 1: Consent

Use `AskUserQuestion`:
- header: "Scan permission"
- options:
  - "Scan everything" (Recommended) — Desktop, Documents, Downloads, Apps, Calendar, Email
  - "Files only" — just Desktop, Documents, Downloads, Apps
  - "Skip" — I'll tell you about myself

### Step 2: Scan (based on consent)

Show progress as each source completes:
```
⏳ Scanning your computer...
  📁 Desktop .............. ✅
  📁 Documents ............ ✅
  📁 Downloads ............ ✅
  💻 Apps ................. ✅
  📅 Calendar ............. ✅
  📧 Email ................ ✅
```

**Desktop & Documents & Downloads:**
```bash
ls ~/Desktop
ls ~/Documents
ls ~/Downloads
```
Only top 2 levels. Extract: project names, industries, tools, patterns.
Downloads: look for recent tools, installers, PDFs that hint at interests/work.

**Applications:**
```bash
ls /Applications
```
Extract: tech stack, creative tools, productivity tools.

**Google Calendar (if MCP available):**
Query upcoming 2 weeks of events.
Extract: meeting patterns, work hours, recurring events, clients.

**Notion (if MCP available):**
List workspaces and top-level pages.
Extract: projects, notes structure, areas of focus.

**Gmail (if MCP available):**
List recent senders/subjects (last 7 days).
Extract: contacts, communication patterns, active projects.

### Step 3: Synthesize
```
"Here's what I learned:

👤 About you: [summary]
💼 Your work: [projects, clients, industry]
🛠️ Your tools: [apps, stack]
📅 Your rhythm: [schedule patterns]
🎯 Active projects: [what you're working on]

Accurate? Anything to correct or add?"
```

### Step 4: Update profile
After confirmation, update `profile.md` with discovered information.
Add entries to Auto-discovered section with source and date.

## Rules
- If a scan source fails or isn't available → skip silently, don't error
- Be respectful of privacy — if folder names suggest personal/sensitive content, don't mention specifics
- Present findings as questions ("It looks like you...?") not assertions
- Maximum 2 levels deep for any directory scan

## Exclusion List

NEVER scan, list, or mention file names from these paths:
- `~/.ssh/`, `~/.gnupg/`, `~/.pgp/`
- `~/.aws/`, `~/.azure/`, `~/.kube/`
- Any path containing: `password`, `credential`, `secret`, `private`, `token`, `.env`
- Any path containing: `medical`, `legal`, `divorce`, `tax-fraud`
- `~/.Trash/`

### Enhanced Privacy Filtering
Exclusion list — NEVER list, scan, or reference:
- ~/.ssh/ (keys)
- ~/.aws/ (credentials)
- ~/.gnupg/ (encryption keys)
- ~/.secrets/ (bOS vault)
- ~/.env* (environment variables)
- ~/.*credentials* (any credentials file)
- ~/.*token* (any token file)
- ~/.*password* (any password file)
- Any file/folder matching: *secret*, *credential*, *token*, *password*, *key* (case-insensitive)
- Browser profile folders (~/Library/Application Support/Google/Chrome/*)
- Keychain files (~/Library/Keychains/*)

**Filtering approach:**
When listing directory contents, FILTER OUT sensitive entries BEFORE showing to user.
If a directory name itself is sensitive (e.g., .ssh) → omit entirely from listing.
User should never see these paths in scan results, even as folder names.

If a scanned file name appears sensitive (medical records, legal documents, financial statements), do NOT include it in the scan summary. Summarize the category instead: "personal documents" not "divorce-papers-2026.pdf".

NEVER persist raw file names to agent memory. Only persist derived insights ("user works in consulting", "user uses Figma").
