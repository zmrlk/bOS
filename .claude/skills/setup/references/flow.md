<!-- Loaded by setup/SKILL.md — the full onboarding flow. -->

# /setup — full flow

Goal: a filled Core section of `profile.md` and first value in under 3 minutes of the user's attention (measured on Claude Code; Codex/Grok use numbered lists instead of clickable cards and take longer — keep the same question cap). Detection over interrogation. Detection is deepest on macOS; on Linux fewer fields auto-detect, which means fewer confirmations, never more questions than the cap.

## Step 0 — scan (non-personal detection first)

If `scripts/profile-scan.sh` exists: `bash .claude/skills/setup/scripts/profile-scan.sh`. The default run detects only non-personal facts (locale, timezone, tool presence, state-file counts). Scanning **names** (installed apps, folders) needs consent first: ask one AskUserQuestion ("May I scan app and folder names — names only, never contents — to prefill your profile?"), and only on yes rerun `bash .claude/skills/setup/scripts/profile-scan.sh --with-names`. Never open file contents at all during setup.

## Step 0.5 — offer the demo (FRESH_INSTALL only)

Before any question, offer one choice: "Want a 30-second demo on sample data first, or straight to your setup?" On demo: run `bash .claude/skills/setup/scripts/demo.sh start` (materializes the Alex fixture; refuses if any real state exists), show one `/morning`-style plan and one `/habit` line from that data, then ask "Ready to make it yours?" and run `bash .claude/skills/setup/scripts/demo.sh end` before continuing. The demo never touches `profile.md` and every fixture file is marked DEMO DATA.

## Step 1 — present, don't ask

Show what you already know in 3-5 lines ("Here's what I can see: …"). Ask for confirmation, not for data. Anything detected or already said in this conversation is never asked again.

## Step 2 — first value

Before any survey: produce one small useful artifact from what exists — today's calendar shape, a task pulled from the stated goal, or a one-line plan. The user should get something before giving something.

## Step 3 — gap questions (max 5)

Only from `gaps_by_leverage`, highest leverage first. One AskUserQuestion at a time, every question skippable. Every question header carries visible progress ("2/5") — the cap is a promise the user can watch you keep. At most two open-text fields total: name (if unknown) and primary goal. Typical high-leverage gaps: primary goal, active packs (Business / Life / Health / Learning), user_type, tech_comfort.

## Step 4 — write and seed

1. Copy `profile-template.md` → `profile.md` (only if missing) and fill confirmed fields. Leave unknown fields empty — never invent.
2. Seed state from the answers: 1-2 tasks derived from the primary goal into `state/tasks.md`, the goal into `state/goals.md`, named habits into `state/habits.md`. Do not overwrite existing `state/*.md`.
3. Welcome message with real counts from `bash scripts/bos-roster.sh` (skills, agents, hooks) — no marketing numbers.
4. **Verify done with code, not with a feeling:** rerun `bash .claude/skills/setup/scripts/profile-scan.sh` and quote its `core_filled` and `mode` lines to the user ("Core 6/6, mode REVIEW — the setup gate is off"). If mode is still FRESH_INSTALL/PARTIAL, setup is NOT done — fill the remaining Core gap or say plainly which question was skipped.
5. Quote the measured duration: elapsed time from the `started:` line in `state/.setup-progress.md` ("that took 2 min 40 s"), then delete the file.
6. **Pay off immediately:** build the day-one plan from what was just gathered — the 1-2 seeded tasks plus one concrete ≤30-min next step from the primary goal. The user leaves with a plan, not a filled form. Close by naming progressive profiling (SKILL rule 12).

## Resume

Progress lives in `state/.setup-progress.md` (step reached + answers so far). If it exists on invocation → continue from that step, don't restart. Delete the file when setup completes.

## Review mode (profile already filled)

`/setup` with a complete profile = refresh, not onboarding: show current values section by section, ask "still true?" only for stale dynamic fields (>30 days), update what changed. Never frame staleness as the user's failure.

## Hard rules (duplicated in SKILL.md on purpose)

Never echo secrets. First user message wins language. Never ask what detection already answered. Value before survey.
