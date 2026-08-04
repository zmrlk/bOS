# /ship — Vibecoding Fast Lane

## Meta
- **Trigger:** `/ship`, "ship it", "zrób commit", "push to git", "commituj", "wypchnij"
- **Agent:** @devlead (routes to @cto for architecture concerns)
- **Model:** haiku (quick) → sonnet if issues found
- **Context needed:** git status, changed files
- **When to use:** After coding session — review → commit → push in one flow

---

## What It Does

Replaces the manual 4-step vibecoding workflow:
```
code → review changes → write commit msg → git add → git commit → git push
```

With one command that does it intelligently.

---

## Flow

### Step 1: Scan Changes
Run `git status` + `git diff --stat` to see what changed.

If no changes → "Nic do shipowania. Workspace czysty."

### Step 2: Quick Review
For each changed file:
- Flag obvious issues (TODO/FIXME left in, console.log, hardcoded secrets, broken imports)
- Note significant changes (new features, removed code, config changes)
- Check if tests exist (if test file exists in project)

**Rules:**
- Max 30 seconds of review — this is FAST lane, not /code review
- Flag only BLOCKERS (would break prod) and WARNINGS (should fix soon)
- Skip style nitpicks

### Step 3: Decision Gate

**If blockers found:**
```
🚫 BLOKERY (napraw przed shipem):
- [file:line] — [issue]

Naprawić teraz? (tak / pomiń / anuluj)
```

**If warnings only:**
```
⚠️ OSTRZEŻENIA (nie blokują):
- [warning]

Kontynuować? (tak / anuluj)
```

**If clean:**
→ Go directly to commit message.

### Step 4: Commit Message
Generate smart commit message from diff summary:
- Format: `type(scope): description` (conventional commits)
- Types: feat / fix / refactor / chore / docs / style / perf
- Max 72 chars
- Polish OK if codebase is Polish

Show message + ask: "OK" / "Zmień" / "Anuluj"

If "Zmień" → user types custom message (1 open text field).

### Step 5: Ship
```bash
git add .
git commit -m "[message]"
git push
```

Show output. If push fails (e.g. upstream not set) → show exact fix command.

### Step 6: Confirm
```
✅ Shipped: [commit hash] — [message]
Branch: [branch] → [remote]
```

---

## Flags

- `/ship --dry` — show what would happen, don't execute
- `/ship --force` — skip review gate (for quick WIP commits)
- `/ship --branch [name]` — push to specific branch
- `/ship --msg "[text]"` — skip message generation, use provided

---

## Context Awareness

Check `state/projects.md` for active project → use correct directory.
If multiple repos detected → ask which one (AskUserQuestion, show changed files per repo).

---

## Rules

1. **Never push without showing commit message first** — always confirm
2. **Never git add -f** — if file is gitignored, it's gitignored for a reason
3. **Never rebase/force-push** — /ship is safe-only. For risky ops → direct git
4. **Secrets check** — scan diff for patterns: `API_KEY`, `SECRET`, `PASSWORD`, `token=` → hard BLOCK
5. **Buffer awareness** — if context-bus has `alert:overloaded` → mention capacity before shipping new features
