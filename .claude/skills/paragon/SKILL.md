---
name: Paragon
description: "Scan receipt photo → auto-extract amount, vendor, category → log to finances.md. Zero typing. Use when user drops a receipt photo, says 'paragon', 'rachunek', or shares a photo of a bill/receipt."
user_invocable: true
command: /paragon
---

# Receipt to Expense (OCR)

User drops a receipt photo → you extract data → log to finances.md.

## Protocol

### Step 1: Read the image
User provides a photo (screenshot, camera photo, or file path). Use the Read tool to view it.

### Step 2: Extract structured data
From the receipt, extract:
- **Vendor/Store name** (e.g., "Żabka", "Auchan", "McDonald's")
- **Total amount** (the final "SUMA" / "DO ZAPŁATY" / "TOTAL")
- **Date** (from receipt, or today if not visible)
- **Items** (top 3-5 items if readable, for category detection)

### Step 3: Auto-categorize
Based on vendor + items, assign category:

| Vendor pattern | Category |
|---------------|----------|
| Żabka, Biedronka, Auchan, Aldi, Kaufland, Dino, Netto, Lidl | Spożywcze |
| McDonald's, KFC, Uber Eats, restaurant names | Jedzenie na mieście |
| Orlen, BP, MOL, Moya, Shell | Paliwo |
| Apteka, pharmacy | Zdrowie (or Używki if amount >200 PLN — ask) |
| Rossmann, Hebe | Drogeryjne |
| Zalando, Reserved, H&M | Ubrania |
| Allegro, AliExpress | Zakupy online |

### Step 4: Confirm with AskUserQuestion
Show extracted data:
```
📸 Paragon:
Sklep: [vendor]
Kwota: [amount] PLN
Data: [date]
Kategoria: [category]
```

AskUserQuestion: "Zalogować?" options: [Tak] [Zmień kategorię] [Anuluj]

### Step 5: Log to finances.md
Append to Expense Log table:
```
| [date] | [amount] PLN | [category] | [vendor] | Nie |
```

Confirm: "⏳ Logged: [vendor] [amount] PLN → [category]"

### Rules:
- If receipt is blurry/unreadable → say what you CAN read, ask for missing data
- If multiple receipts in one photo → process each separately
- Never guess amounts — if unclear, ask
- Round to grosze (2 decimal places)
- Impulse detection: if purchase is >100 PLN AND category is Rozrywka/Ubrania/Zakupy → mark Impulse = "?" and ask
