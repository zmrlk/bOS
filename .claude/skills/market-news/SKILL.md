---
name: Market News
description: "Financial news aggregation — key market events, trends, what matters for your portfolio. Use when user asks 'co na rynkach?', 'market news', 'co sie dzieje na gieldzie?', or wants a market briefing."
user_invocable: true
command: /market-news
---

# /market-news — Market Briefing

What's happening in markets, filtered for what matters to YOU.

---

## Usage

- `/market-news` — today's market briefing
- `/market-news "topic"` — news about specific sector/asset
- `/market-news week` — weekly market summary

---

## Protocol

### Step 1: Batch data loading (1 turn, all parallel)

Issue ALL reads in one batch:
- `state/portfolio.md` (Summary) → user's holdings for relevance filtering
- @investor memory → investment_layer, risk_profile

### Step 2: Fetch news

Use WebSearch queries (parallel, max 3):

**Default briefing:**
1. `"stock market today summary [date]"` — global overview
2. `"GPW Warsaw stock exchange today"` — Polish market (if user has Polish holdings)
3. `"ETF market news [date]"` — ETF-specific (if user holds ETFs)

**Topic-specific:**
1. `"[topic] market news today [date]"`
2. `"[topic] stock analysis [date]"`

**Weekly:**
1. `"stock market weekly summary [date range]"`
2. `"S&P 500 weekly performance"`
3. `"emerging markets weekly news"`

### Step 3: Filter and display

Filter news by relevance to user's portfolio and layer:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📰  MARKET BRIEFING — [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  🔴 WAŻNE DLA CIEBIE:
  • [News relevant to user's holdings]
  • [News relevant to user's holdings]

  🌍 GLOBAL:
  • [Key global market event]
  • [Key global market event]

  🇵🇱 POLSKA:
  • [Polish market news]

  📊 INDEKSY:
  S&P 500: [value] ([%])
  WIG20: [value] ([%])
  EUR/PLN: [value]

  💡 CO TO ZNACZY:
  [1-2 sentences explaining impact on
   user's portfolio/strategy in plain Polish]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Layer-aware commentary

| Layer | Commentary style |
|-------|-----------------|
| 1 | "S&P spadl 2%. To normalne. Twoj ETF kupujesz co miesiac — spadek = taniej kupujesz." |
| 2 | "Sektor tech pod presja przez stopy procentowe. Twoj VWCE ma ~20% tech — wplyw umiarkowany." |
| 3+ | "Yield curve uninverted. Historycznie — 6-12 msc do recesji. Rozważ zwiększenie obligacji." |

### Step 5: Action signal (if warranted)

Only suggest action when CLEARLY relevant:
- Market crash >5% → "Nie panikuj. DCA oznacza że kupujesz taniej. To dobrze."
- User's holding dropped >10% in a week → "Sprawdź czy fundamenty się zmieniły: /stock-check [ticker]"
- Tax-relevant event (dywidenda) → "Dywidenda [X] — sprawdź rozliczenie podatkowe"

Most days: NO action needed. Say so explicitly: "Dziś nic nie musisz robić. DCA działa za ciebie."

## Context-Bus Signals

| Condition | Signal |
|-----------|--------|
| Market crash >5% weekly | `@investor → ALL, Type: data, Priority: critical, TTL: 7d, Content: Market drop [X]%. Calm advisory posted.` |
| News directly impacts user's holding | `@investor → @boss, Type: data, Priority: normal, TTL: 3d, Content: [Holding] affected by [event].` |

## State Files
- **Read:** state/portfolio.md (S)
- **Write:** none

## Rules
1. All news from WebSearch — never fabricate
2. Always date-stamp: "Dane z: [date]"
3. Filter for relevance — user doesn't need ALL market news, just what affects them
4. Layer-appropriate language — no jargon for Layer 1
5. CALM tone during volatility — never amplify fear
6. "Nic nie rob" is a valid recommendation — most days, doing nothing is correct
7. Max 3 WebSearch queries per invocation
8. Language = Polish
9. Disclaimer on first use: "To nie jest porada inwestycyjna."
