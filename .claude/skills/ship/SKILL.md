---
name: ship
description: "Review changes and commit. Push is a separate ask. Use when the user says /ship, ship it, commit, or wypchnij."
user_invocable: true
command: /ship
tier: core
---

# /ship — Vibecoding Fast Lane

## Meta
- **Trigger:** `/ship`, "ship it", "commit it", "push to git"
- **Agent:** @cto
- **Model:** haiku (quick) → sonnet if issues found
- **Context needed:** git status, changed files
- **When to use:** After coding — review → commit. Push is a separate, explicit ask.

---

## What It Does

Replaces the manual 4-step vibecoding workflow:
```
code → review → commit message → git add → git commit
(push only after a second, explicit yes)
```

With one command that does it intelligently.

---

## Flow

### Step 1: Scan Changes
Run `git status` + `git diff --stat` to see what changed.

If no changes → "Nothing to ship. Workspace clean."

### Step 2: Quick Review
For each changed file:
- Flag obvious issues (TODO/FIXME left in, console.log, hardcoded secrets, broken imports)
- Note significant changes (new features, removed code, config changes)
- Check if tests exist (if test file exists in project)

**Rules:**
- Max 30 seconds of review — this is FAST lane, not /ship review
- Flag only BLOCKERS (would break prod) and WARNINGS (should fix soon)
- Skip style nitpicks

### Step 3: Decision Gate

**If blockers found:**
```
🚫 BLOCKERS (fix before shipping):
- [file:line] — [issue]

Fix now? (yes / skip / cancel)
```

**If warnings only:**
```
⚠️ WARNINGS (non-blocking):
- [warning]

Continue? (yes / cancel)
```

**If clean:**
→ Go directly to commit message.

### Step 4: Commit Message
Generate smart commit message from diff summary:
- Format: `type(scope): description` (conventional commits)
- Types: feat / fix / refactor / chore / docs / style / perf
- Max 72 chars
- Polish OK if codebase is Polish

Show message + ask: "OK" / "Change" / "Cancel"

If "Change" → user types custom message (1 open text field).

### Step 5: Commit (default)
```bash
git add <only the files you reviewed in Step 2 — named explicitly, never `.`>
git commit -m "[message]"
```

Do **not** `git push`. `settings.json` denies `git push`. If the user still wants push: AskUserQuestion "Push to remote?" [Not now] [Yes, push]. Only then run `git push` after they pick Yes.

### Step 6: Confirm
```
✅ Committed: [commit hash] — [message]
Push: not done (ask if you want it)
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

1. **Never push inside the default flow** — commit only; push needs a second yes
2. **Never git add -f** — if file is gitignored, it's gitignored for a reason
3. **Never rebase/force-push** — /ship is safe-only. For risky ops → direct git
4. **Secrets check** — scan diff for patterns: `API_KEY`, `SECRET`, `PASSWORD`, `token=` → hard BLOCK
5. **Explicit staging only** — name every file you stage; `git add .` / `-A` are forbidden in this skill
6. **Staged-diff privacy gate** — before commit, run `git diff --cached --name-only`; any path under `state/` or `profile.md` or `.secrets/` → UNSTAGE it and tell the user (personal data never ships, even if someone broke the gitignore)
7. **Buffer awareness** — if context-bus has `alert:overloaded` → mention capacity before shipping new features
