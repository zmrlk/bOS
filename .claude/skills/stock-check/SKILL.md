---
name: Stock Check
description: "Quick stock/ETF data lookup — price, performance, basic metrics. Use when user asks 'ile kosztuje VWCE?', 'jak stoi S&P500?', stock price, ETF check, or market data."
user_invocable: true
command: /stock-check
---

# /stock-check — Market Data Lookup

Quick price and performance data for stocks, ETFs, and indices.

---

## Usage

- `/stock-check VWCE.DE` — check specific ticker
- `/stock-check S&P500` — check index
- `/stock-check portfolio` — check all holdings from portfolio.md

---

## Protocol

### Step 1: Identify ticker

Map common names to Yahoo Finance tickers:

**Common Polish investor tickers:**
| Name | Ticker | Type |
|------|--------|------|
| S&P 500 | ^GSPC | Index |
| MSCI World | URTH | ETF |
| VWCE (Vanguard FTSE All-World) | VWCE.DE | ETF |
| WIG20 | ^WIG20 | Index |
| WIG | ^WIG | Index |
| ETFSP500 (Beta ETF S&P500) | ETFSP500.WA | ETF (GPW) |
| ETFW20L (Beta ETF WIG20) | ETFW20L.WA | ETF (GPW) |
| iShares MSCI World | IWDA.AS | ETF |
| Bitcoin | BTC-USD | Crypto |
| Gold | GC=F | Commodity |
| EUR/PLN | EURPLN=X | Forex |
| USD/PLN | USDPLN=X | Forex |

If ticker not in list → use WebSearch to find Yahoo Finance ticker.

### Step 2: Fetch data

Use WebSearch: `"[ticker] yahoo finance stock price"`

Extract:
- Current price
- Daily change (% and absolute)
- 1 month, 3 month, YTD, 1 year performance
- 52-week high/low
- For ETFs: TER (expense ratio), AUM

### Step 3: Display

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📊  [NAME] ([TICKER])
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Cena: [price] [currency]
  Dziś: [+/-X.XX%] ([+/-absolute])

  | Okres | Zmiana |
  |-------|--------|
  | 1 msc | [%]    |
  | 3 msc | [%]    |
  | YTD   | [%]    |
  | 1 rok | [%]    |

  52W: [low] — [high]
  [For ETFs: TER: X.XX% | AUM: $XB]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Subcommand: `/stock-check portfolio`

1. Read `state/portfolio.md` → holdings list
2. Fetch data for each holding (parallel WebSearch)
3. Show combined view:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  💼  PORTFOLIO CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  | Holding | Waga | Cena | Dziś | YTD |
  |---------|------|------|------|-----|
  | [X]     | [%]  | [p]  | [%]  | [%] |
  | [Y]     | [%]  | [p]  | [%]  | [%] |

  Portfel ogółem: ~[value] PLN
  Dziś: [+/-X.XX%]
  YTD: [+/-X.XX%]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Educational context (Layer-aware)

Based on @investor memory investment_layer:
- **Layer 1:** Add 1-line explanation: "ETF VWCE to koszyk 3700 firm z calego swiata. Kupujesz kawalek wszystkiego."
- **Layer 2:** Add context: "P/E sektora tech jest teraz [X], historyczna srednia [Y]."
- **Layer 3+:** Skip basics, show deeper metrics if available.

## State Files
- **Read:** state/portfolio.md (holdings list)
- **Write:** none

## Rules
1. All data from WebSearch — no fabricated prices
2. Always show data freshness: "Dane z: [date/time]"
3. ⚠️ disclaimer on first use: "Dane mogą być opóźnione 15-20 min. To nie jest porada inwestycyjna."
4. If WebSearch fails → inform honestly, suggest checking directly
5. Max 5 tickers per query (batch)
6. Currency context: show PLN equivalent for foreign-denominated assets
7. Language = Polish
