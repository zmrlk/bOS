---
name: Content Repurposing
description: "Repurpose content across platforms — turn one piece into LinkedIn, Twitter/X, Instagram, TikTok, and email versions. Use when the user has content they want to distribute across multiple channels."
user_invocable: true
command: /repurpose
---

# /repurpose — Content Repurposing Pipeline

Turn one piece of content into platform-specific versions for all your channels. Powered by @cmo.

**Validated:** 88% of marketers report 20-40% speed gain; saves up to 80% of content creation time.

**Adapt to tech_comfort:** "not technical" → focus on copy-paste output. "I use apps" → mention scheduling tools. "I code" → technical format options.

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → brand_voice, active_platforms, target_audience

---

## Protocol

### Step 1: Source Content
Ask user to provide source:
`AskUserQuestion`:
- header: "Source"
- options:
  - "Blog post / article" (description: "Paste or link the content")
  - "Video transcript" (description: "Paste the transcript")
  - "Topic / idea" (description: "I'll describe what I want to talk about")
  - "Recent project" (description: "Turn a completed project into content")

### Step 2: Platform Selection
`AskUserQuestion`:
- header: "Platforms"
- multiSelect: true
- options: [from profile.md active_platforms, e.g.:]
  - "LinkedIn" (description: "Professional thought leadership")
  - "Twitter/X" (description: "Thread or single tweet")
  - "Instagram" (description: "Visual-first caption")
  - "TikTok" (description: "Short video script")

If no active_platforms in profile → show all 4 options.

### Step 3: Generate Platform-Specific Versions

For each selected platform, generate adapted content:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📣 CONTENT REPURPOSED — [X] versions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**LinkedIn:**
```
📝 LINKEDIN — ready to copy
────────────────────────────────
[Hook — first 2 lines, click "see more" worthy]

[Body — professional tone, thought leadership,
 3-5 short paragraphs, personal angle]

[CTA — question or call to action]

#[relevant hashtags, max 5]
────────────────────────────────
```

**Twitter/X:**
```
🐦 TWITTER/X THREAD — ready to copy
────────────────────────────────
1/ [Hook tweet — under 280 chars, punchy]

2/ [Context / problem]

3/ [Insight / solution]

4/ [Data / proof]

5/ [Lesson learned]

6/ [CTA — follow, retweet, reply]

7/ TL;DR: [one-line summary]
────────────────────────────────
```

**Instagram:**
```
📸 INSTAGRAM — ready to copy
────────────────────────────────
[Caption — storytelling, personal, visual-first]

[Break into short paragraphs]

[CTA]

.
.
.
[Hashtags — 15-20, mix popular + niche]
────────────────────────────────
Visual idea: [describe ideal image/carousel concept]
```

**TikTok:**
```
🎬 TIKTOK SCRIPT — ready to film
────────────────────────────────
HOOK (0-3s): [attention grabber — statement or question]
BODY (3-40s): [storytelling, tips, process]
CTA (40-60s): [follow, comment, save]

Style: [talking head / b-roll / text overlay]
Trending: [suggest audio/format if relevant]
────────────────────────────────
```

**Email Newsletter:**
```
📧 EMAIL SNIPPET — ready to copy
────────────────────────────────
Subject: [compelling subject line]

[Opening — personal hook]

[Main content — adapted from source, shorter]

[CTA — link, reply, forward]

[Sign-off]
────────────────────────────────
```

### Step 4: Next Steps
`AskUserQuestion`:
- header: "Next"
- options:
  - "Copy all" (description: "Everything ready to paste")
  - "Edit a version" (description: "Tweak one platform")
  - "Schedule" (description: "Plan publishing times")

If social MCPs connected → offer: "Publish directly to [platform]?"

---

## State Files
- **Read:** profile.md (brand_voice, platforms, audience)
- **Write:** None

---

## Rules

1. Each platform version maintains brand voice from profile.md
2. Content is NEVER just reformatted — it's genuinely adapted for each platform's audience and format
3. LinkedIn = professional. Twitter = punchy. Instagram = visual. TikTok = hook-first.
4. All versions are copy-paste ready — no placeholders
5. All reads in 1 batch turn
6. Use AskUserQuestion for all choices
7. If source content is long → distill, don't truncate
8. Language matches user's language from profile.md
9. Max 2 context-bus signals per execution
