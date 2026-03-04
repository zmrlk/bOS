---
name: Quick Note
description: "Instant capture to state/notes.md. No friction. Use when user says zanotuj, notatka, note, or remember this."
user_invocable: true
command: /note
model: haiku
---

# /note — Quick Capture

## Trigger
- `/note` or `n [text]`
- "zanotuj", "zapisz", "notatka", "note", "remember this"

## What it does
Instant capture to `state/notes.md`. No questions, no formatting overhead. Just save and confirm.

bOS reads notes during /morning and /home — understands context (deadlines, reminders, ideas, todos).

## Usage

### Quick capture
```
n BDO do 15 marca
n zadzwonić do Radka w sprawie pitch
n pomysł: karty lojalnościowe w STAGO
```

### List notes
```
/note list
notatki
```

### Delete note
```
/note done 3
/note delete 2
```

## Flow

### Capture (`n [text]` or `/note [text]`)
1. Parse text — detect type: `reminder` (has date/deadline), `idea` (pomysł/idea), `todo` (action words), `note` (default)
2. Append to `state/notes.md` under Active section
3. If date detected → extract and add to entry
4. Confirm: `📌 Zapisane: "[text]"`
5. If reminder with date → mention it'll surface in /morning

### List (`/note list`)
1. Read `state/notes.md`
2. Show numbered list with type icons: 📅 reminder | 💡 idea | ✅ todo | 📌 note
3. Quick actions: "Delete any?" (numbered)

### Done/Delete (`/note done [N]` or `/note delete [N]`)
1. Move entry to Archive section in notes.md
2. Confirm: `✅ Usunięte: "[text]"`

## State file: `state/notes.md`

```markdown
# Notes

## Summary
| Total | Reminders | Ideas | Todos |
|-------|-----------|-------|-------|
| 5     | 2         | 1     | 2     |

## Active

### 2026-03-03 📅 BDO do 15 marca
Type: reminder | Due: 2026-03-15

### 2026-03-03 💡 Karty lojalnościowe w STAGO
Type: idea

### 2026-03-03 ✅ Zadzwonić do Radka w sprawie pitch
Type: todo

---

## Archive
```

## Integration
- **/morning** reads Active notes, surfaces reminders due today/tomorrow
- **/home** shows note count + nearest reminder
- **/evening** asks "Any notes to capture before end of day?"
- **@boss** checks for overdue reminders during session start

## Rules
1. ZERO questions on capture. `n text` → saved. Period.
2. Date parsing: "do 15 marca", "jutro", "w piątek", "next week" → extract to Due field
3. Max display: 10 notes in list. Older → "X more in archive"
4. Don't duplicate — if very similar note exists, update instead of creating new
5. Language: user's language for everything
