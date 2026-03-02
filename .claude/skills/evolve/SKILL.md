---
name: Self-Evolution
description: "bOS improves itself — searches for new MCPs, re-verifies existing ones, creates skills from patterns, delivers fresh data. Runs proactively or on demand."
user_invocable: true
command: /evolve
---

# bOS — Self-Evolution

## Philosophy

bOS is not static software — it's a **living system** that grows with the user. It doesn't just remember — it LEARNS, DISCOVERS, and IMPROVES. The user hired an expert team. Experts stay sharp.

---

## When This Runs

### Automatic triggers (proactive, via @boss):
- **Weekly** (Sunday evening, before /plan-week): Quick evolution check
- **After 2 weeks of use**: First deep evolution scan
- **Monthly** (during maintenance): Full evolution cycle
- **After major life change** (new job, new goal, new pack activated): Targeted discovery

### Manual trigger:
- User says `/evolve` or "improve yourself" / "what's new" / "upgrade"

---

## Evolution Cycle (5 phases)

### Phase 1A: DISCOVER — Search for new capabilities

**MCP Discovery (matching user's tools + needs):**

```
⏳ Searching for new capabilities...
```

Batch WebSearch queries based on profile.md:
- User's tools (from scan) without MCP → "[tool] MCP server Claude [current year]"
- User's packs with gaps → "Claude MCP [domain: fitness/finance/productivity/learning]"
- Aggregators → WebFetch "mcp.so", "glama.ai/mcp" for latest listings
- Community → "best new MCP servers Claude Code reddit" (current year)
- Voice/dictation → "Claude MCP voice dictation speech-to-text [current year]" (for voice mode users)

**Security filter (MANDATORY — same checklist as setup 5C):**

Every MCP must pass ALL 8 criteria before being proposed:

- [ ] **GitHub ≥100 stars** OR official Anthropic/Claude marketplace listing
- [ ] **Last commit < 3 months** (actively maintained — check date on GitHub)
- [ ] **Positive reviews on ≥2 sources** (Reddit + GitHub issues, or X + Reddit, etc.)
- [ ] **No sudo/root/admin** required — no privileged permissions
- [ ] **Open source** — full source code available for review
- [ ] **Clear permissions** — README clearly describes WHAT the MCP does and what it accesses
- [ ] **No red flags in issues** — check GitHub issues for: "security", "vulnerability", "malware", "data leak"
- [ ] **Known community** — author has GitHub history, not an anonymous single-repo account

**Scoring: Each MCP gets a 1-10 rating:**
- 10: Official Anthropic marketplace + >1000 stars + active + zero issues
- 9: >500 stars + active + positive reviews on 2+ sources + known author
- 8: >100 stars + active + positive reviews + no red flags + open source
- <8: DO NOT PROPOSE — did not pass security audit

**ABSOLUTE RULE:** Better to propose NOTHING than to propose something scoring <8/10. The user trusts us.

**Typosquatting check (CRITICAL):** Before any npx installation, verify the package name matches the GitHub repo EXACTLY. Compare npm package name with GitHub repo URL. If mismatch → do NOT install, flag to user.

### Phase 1B: RE-VERIFY — Check existing MCPs

**TRIGGER:** Runs alongside Phase 1A during monthly and deep evolution cycles.

For each MCP in profile.md → `Connected MCPs`:
1. **Test connectivity:** Make a simple test call to each connected MCP
   - Desktop Commander → try `ls ~/Desktop`
   - Google Calendar → try reading today's events
   - Gmail → try listing recent emails
   - Supabase → try `SELECT 1`
   - Other → appropriate test call per MCP type
2. **Check for updates:** WebSearch "[mcp-name] update changelog [current year]"
   - New version available? → note for Phase 3
   - Deprecated? → warn user, suggest replacement
   - Security advisory? → IMMEDIATE escalation (see Security Incident Response below)
3. **Check usage:** Does the user actually USE this MCP?
   - Check agent memory for MCP-related interactions in the last 30 days
   - If connected but unused for 60+ days → flag for user: "You have [MCP] connected but haven't used it. Keep or remove?"
4. **Re-score security:** Re-run the 8-point security checklist
   - Stars dropped below 100? Activity stopped? Red flags appeared?
   - If score dropped below 8 → warn user: "⚠️ [MCP] no longer meets our security standards. Recommend removing."

**Report format:**
```
  🔍  Existing connections check:

  ✅ [MCP 1] — working, up to date
  ✅ [MCP 2] — working, update available (v1.2 → v1.5)
  ⚠️ [MCP 3] — connected but unused (60 days)
  ❌ [MCP 4] — connection failed (test call error)
```

### Phase 2: EVALUATE & FILTER

**2A. Knowledge Freshness:**

- Check profile.md fields with dates → flag anything >3 months old
- Check agent calibrations → flag stale entries (>60 days no update)
- Check pricing/tools referenced in agent memory → verify current accuracy via WebSearch

**2B. State Data Verification:**

- Goals still relevant? (>3 months without progress → flag for @coach)
- Pipeline leads still alive? (>30 days no update → flag for @sales)
- Financial data current? (income/expenses from >2 months ago → flag for @finance/@cfo)

**2C. Skill Pattern Detection:**

Check agent memory + state files for repeated patterns:
- Does the user do X more than 3x/week manually? → candidate for a new skill
- Examples:
  - Logs expenses at the same time daily → enhance /expense with auto-prompts
  - Asks about the same topic weekly → create a dedicated briefing
  - Does a recurring multi-step process → package as a skill

If pattern detected:
```
I noticed you regularly [pattern]. I can create
a shortcut /[name] so you can do it with one command.
Want me to?
```

**2D. Tool & Integration Discovery:**

Based on user's workflow:
- Missing calendar integration? → find and suggest
- Missing email integration? → find and suggest
- Uses a tool bOS doesn't know about? → research it, find MCP or workaround

### Phase 3: PRESENT — Show findings to user

**Present findings (max 5 items, prioritized):**

**Adapted to tech_comfort:**

**"not technical":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔄  Ideas to help you better
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  I searched the internet and analyzed
  our conversations. Here's what I found:

  1. ✨ [New capability] — [1 sentence benefit]
  2. 🔄 [Update] — [1 sentence what changed]
  3. ⚡ [Optimization] — [1 sentence improvement]

  Want me to set any of these up?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**"I use apps":**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🔄  Evolution Report
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  DISCOVERED:
  ✨ [Extension/skill] — [description]

  EXISTING CONNECTIONS:
  ✅ [Connected OK] | ⚠️ [Needs attention]

  STALE DATA:
  🔄 [field/calibration] — last updated [X] days ago

  PATTERNS:
  ⚡ [repeated action] — shortcut candidate?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**"I code":**
```
  🔄  Evolution Report

  DISCOVERED:
  ✨ [MCP/skill] — [description] (GitHub: ⭐[X], score: [X]/10)

  EXISTING MCPs:
  ✅ [OK] | ⚠️ [Update available] | ❌ [Failed]

  STALE DATA:
  🔄 [field/calibration] — last updated [X] days ago

  PATTERNS:
  ⚡ [repeated action] — skill candidate?

  Actions: install / update / skip / remove
```

**AskUserQuestion:**
- header: "Improvements"
- question: "What would you like to do?"
- options:
  - "Apply all recommended" (description: "I'll install new extensions, update stale data, create shortcuts")
  - "Let me choose" (description: "I'll show a checklist to pick from")
  - "Not now" (description: "Come back to this later")

### Phase 4: UPGRADE — Implement approved changes

**4A. Execute approved changes:**
- Install new MCPs: `⏳ Installing [name]... ✅`
  - **Installation methods (try in order):**
    1. Anthropic marketplace → `marketplace enable [name]` (easiest)
    2. npx → `npx -y [package-name]` (no global install)
    3. Manual config → add to `.claude/settings.json` mcpServers (last resort, "I code" users only)
  - **Typosquatting check:** Verify package name matches GitHub repo EXACTLY before executing
  - Show exact command to user before executing: "Installing [package-name] from [github-url]. OK?"
- Update MCPs: if update available → install new version, test, report
- Remove MCPs: if user approves removal of unused/unsafe MCP → remove from settings, update profile
- Create new skills: generate SKILL.md, save to `.claude/skills/`
- Update stale data: prompt user for current values OR research online
- Update profile.md → connected_mcps, bos_version metadata

**4B. Verify changes:**
After each installation:
1. Make a test call to verify the new MCP works
2. If test fails → rollback, inform user: "❌ [name] didn't work. Rolled back."
3. If test passes → confirm: "✅ [name] installed and verified."

### Phase 5: LEARN — Reflect on what worked

After each evolution cycle:
- Log what was proposed, accepted, rejected to agent memory
- Track: which MCPs user actually uses (install ≠ usage)
- Track: which skills user invokes (created ≠ used)
- Adjust future recommendations based on acceptance patterns
- If user consistently rejects a type of suggestion → stop suggesting it

---

## Security Incident Response

If during Phase 1B re-verification, a connected MCP is found to have:
- A new security advisory or CVE
- Malware reports in GitHub issues
- Author account compromised
- Package removed from npm/registry

**Immediate actions:**
1. **ALERT USER:** "⚠️ SECURITY: [MCP name] has a reported security issue. I recommend disconnecting it immediately."
2. **Show evidence:** Link to the advisory/report
3. **Offer to disconnect:** AskUserQuestion with "Disconnect now (recommended)" / "I'll review myself"
4. **If disconnected:** Remove from settings.json, update profile.md → Connected MCPs
5. **Search for replacement:** Find an alternative MCP that passes the security checklist
6. **Log:** Record the incident in agent memory for future reference

---

## Lightweight Scan (for weekly checks)

Not every evolution needs a full cycle. Weekly checks (Sunday evening) use a lightweight version:

1. **Quick MCP health:** Test call to each connected MCP — just verify they respond
2. **Quick pattern check:** Any new repeated actions in the last 7 days?
3. **Stale data check:** Any profile fields or calibrations updated >60 days ago?
4. **Quick web scan:** One batch WebSearch for "[user's primary tools] MCP new [current year]"

If anything notable found → surface in /plan-week: "During my weekly check, I found [X]. Want me to look deeper? Say /evolve."

If nothing found → log silently, no user interruption.

---

## Evolution State Tracking

Track evolution history in agent memory:

```
Evolution cycle: [date]
Type: [weekly-light / monthly-full / manual / triggered]
Discovered: [list of new MCPs/skills found]
Proposed: [what was shown to user]
Accepted: [what user approved]
Rejected: [what user declined]
Installed: [what was successfully installed]
Failed: [what failed installation]
Removed: [what was removed]
Security: [any security incidents]
```

This history informs future evolution cycles:
- User rejected fitness MCPs twice → stop suggesting fitness MCPs
- User loves productivity tools → prioritize productivity discoveries
- MCP X was installed but never used → flag in next cycle

---

## Fresh Data Delivery (integrated with /morning)

bOS checks profile.md for user interests and delivers current information:

**How to detect interests:**
- profile.md → primary_goal, active_packs, industry, interests
- Agent memory → topics user asks about repeatedly
- Explicit: user says "I'm interested in politics" / "I want to track the market"

**What to deliver (in /morning briefing, as optional section):**

| Interest | Source | Format |
|----------|--------|--------|
| Politics/news | WebSearch "[country] news today" | 2-3 bullet headlines |
| Markets/stocks | WebSearch "[index/stock] price today" | Price + % change |
| Weather | WebSearch "weather [location] today" | Temp + condition |
| Industry news | WebSearch "[industry] news this week" | 1 key development |
| Tech/tools | WebSearch "new [tool] updates" | Notable updates only |

**Rules:**
- Max 3 fresh data items per morning (don't overwhelm)
- Only deliver for explicitly stated or strongly detected interests
- Always cite source
- If WebSearch fails → skip silently, don't show empty section
- User can say "no news" → set flag in profile.md, never show again

---

## Skill Auto-Creation Protocol

When bOS detects a repeating pattern worth automating:

1. **Detect:** 3+ occurrences of same multi-step process in 2 weeks
2. **Propose:** "I see you regularly do [X]. Create a shortcut?"
3. **If approved → Generate skill:**
   - Create `.claude/skills/[name]/SKILL.md` with proper frontmatter
   - Define: trigger, steps, state files, agent routing
   - Test mentally: does this skill make sense standalone?
4. **Register:** Add to natural language routing in CLAUDE.md (or inform user of the command)
5. **Monitor:** Track usage for 2 weeks. If unused → offer to remove

**Never auto-create without user approval.** Always explain what the skill will do.

---

## Self-Improvement Areas

| Area | How bOS improves | Frequency |
|------|-----------------|-----------|
| **MCPs** | Search for new integrations matching user's tools | Monthly |
| **Existing MCPs** | Re-verify connectivity, security, usage | Monthly |
| **Skills** | Detect patterns, propose new skills | Ongoing |
| **Agent knowledge** | Verify frameworks/methods are current | Monthly |
| **User data** | Flag stale profile fields, suggest updates | Every 5th session |
| **Calibrations** | Self-Calibration per agent (already in agent files) | Monthly |
| **Fresh data** | Real-time info in morning briefings | Daily |
| **Memory** | Consolidate, archive, resolve contradictions | Monthly |
| **Signals** | Review context-bus effectiveness | Monthly |
| **Security** | Re-score connected MCPs, check advisories | Monthly |

---

## Rules

1. **Always ask before installing anything.** Discovery ≠ installation.
2. **Show your sources.** Every recommendation backed by a link.
3. **Max 5 suggestions per cycle.** Quality > quantity.
4. **Respect user's rejections.** If they say "no MCPs" → stop suggesting MCPs.
5. **Security first.** Never suggest unverified tools. Score <8 = reject.
6. **Don't fix what works.** If the user's workflow is smooth, don't disrupt it.
7. **Token awareness.** Full evolution cycle is heavy. Warn before running: "This will use more resources than a normal conversation." Adapt phrasing to tech_comfort.
8. **Log everything.** Every evolution cycle logged to agent memory for learning.
9. **Re-verify regularly.** Connected ≠ safe forever. Monthly re-checks are mandatory.
10. **Adapt language.** Present all findings in the user's language (from profile.md). Search queries stay English (MCP ecosystem is English-first).
