---
name: Design Support
description: "Design briefs, social media content creation, brand consistency checks. Use when the user needs to create social media posts, design briefs, or check brand consistency."
user_invocable: true
command: /design
---

# /design — Design Support

Create design briefs, social media content, and check brand consistency. Powered by @cmo.

**MCP-dependent:** Canva (if connected), Replicate (optional, for AI image gen).

**Adapt to tech_comfort:** "not technical" → visual descriptions, no design jargon. "I use apps" → name tools. "I code" → technical specs.

---

## Subcommands

| Command | What it does | When to use |
|---------|-------------|------------|
| `/design brief` | Create structured design brief | Starting a design project |
| `/design social [platform]` | Generate social media content (copy + visual direction) | Creating social posts |
| `/design brand-check` | Review brand consistency | Brand audit |

---

## Data Sources (batch loading — 1 turn)

**Issue ALL reads in one batch:**
- `profile.md` (full) → brand_voice, active_platforms, target_audience, business description

---

## /design brief — Create Design Brief

### Protocol:
1. Read profile.md
2. `AskUserQuestion`:
   - header: "Type"
   - options:
     - "Social media post" (description: "For any platform")
     - "Banner / cover image" (description: "Website, LinkedIn, etc.")
     - "Presentation" (description: "Slides for a talk or meeting")
     - "Logo concept" (description: "Brand identity element")
3. Gather details via `AskUserQuestion` for purpose, key message
4. Auto-fill: brand style from profile.md
5. Generate structured brief:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎨 DESIGN BRIEF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  TYPE: [post / banner / presentation / logo]
  PURPOSE: [what it's for]
  AUDIENCE: [from profile.md]

  DIMENSIONS
  → [platform-specific: 1080x1080 for Instagram, etc.]

  KEY MESSAGE
  → [headline / main text]

  COPY
  → Headline: [text]
  → Body: [text]
  → CTA: [text]

  VISUAL DIRECTION
  → Style: [from brand_voice]
  → Colors: [suggest based on brand]
  → Imagery: [describe visual concept]
  → Mood: [professional / playful / bold / etc.]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

6. If Canva MCP connected → `AskUserQuestion`: "Create in Canva?" / "Just the brief"
7. If Replicate MCP connected → offer AI image generation

---

## /design social [platform] — Social Media Content

### Protocol:
1. Read profile.md (brand_voice, active_platforms)
2. If no platform specified → `AskUserQuestion`:
   - header: "Platform"
   - options: [from profile.md active_platforms]
3. Generate platform-specific content:

**LinkedIn:**
```
📣 LINKEDIN POST — ready to copy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Hook — first 2 lines that make people click "see more"]

[Body — 3-5 short paragraphs, personal story or insight]

[CTA — question or call to action]

#[relevant] #[hashtags] #[max5]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Visual: [describe ideal image/graphic]
Best time: Tue-Thu 7:30-8:30am or 11:30-12:30pm
```

**Instagram:**
```
📸 INSTAGRAM POST — ready to copy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Caption — visual-first, storytelling]

[Hashtags — 15-20 relevant, mix of popular and niche]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Visual: [describe photo/graphic concept]
Format: 1080x1080 (feed) or 1080x1920 (story/reel)
```

**Twitter/X:**
```
🐦 TWITTER/X POST — ready to copy
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Tweet — under 280 chars, punchy]

[If thread: tweet 1/N format]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**TikTok:**
```
🎬 TIKTOK SCRIPT — ready to use
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Hook (0-3s): [attention grabber]
Body (3-30s): [main content, storytelling]
CTA (30-60s): [what to do next]

Trending audio: [suggest if available]
Hashtags: [relevant TikTok hashtags]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. MCP integration:
   - If social platform MCP → "Publish directly?" via AskUserQuestion
   - If Canva MCP → "Create graphic in Canva?"
   - If no MCPs → content is copy-paste ready

---

## /design brand-check — Brand Consistency

1. Read profile.md (brand_voice, active_platforms)
2. Review user's brand presence:
   - Consistent messaging across platforms?
   - Brand voice alignment?
   - Visual consistency?
3. Report with recommendations

---

## Graceful Degradation

| With MCP | Without MCP |
|----------|-------------|
| Canva → create directly | Design brief (text) |
| Replicate → AI image | Describe visual concept |
| Social MCP → publish | Copy-paste ready text |

---

## State Files
- **Read:** profile.md (brand_voice, platforms, audience)
- **Write:** None

---

## Rules

1. Content ALWAYS copy-paste ready — no placeholders
2. Platform-specific dimensions and formats
3. Brand voice from profile.md shapes all content
4. CTA in every piece of content
5. All reads in 1 batch turn
6. Use AskUserQuestion for all choices
7. Language matches user's language from profile.md
8. Max 2 context-bus signals per execution
