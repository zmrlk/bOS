# External audit — v0.13.0 (commit 5eaa66c), 2026-08-26

> **STATUS: all P0/P1 findings below were fixed in v0.13.1** (branch `fix/p0-data-boundary`, merged as `5f0cf23` + tail `ec68513`). This document describes the PRE-fix state; the Response table at the bottom maps each finding to its fix.

Independent multi-model audit of the public tree (host session + council: Claude 7/10 CONDITIONAL GO, GLM 6/10 CONDITIONAL GO with independent reproduction of all key findings; Grok timeout ×2; Gemini empty). Overall verdict: **6.0/10 — CONDITIONAL GO** as an experimental project for technical early adopters; **NO-GO for broader promotion as a safe personal OS until private data is separated from code**. Concept/positioning rated ~8/10.

| Area | Score |
|------|-------|
| Idea & user value | 8/10 |
| README & transparency | 7/10 |
| Hook/script correctness | 6/10 |
| Privacy & security | 4/10 |
| Architecture & maintenance | 6/10 |
| Tests & CI | 7/10 |
| Cross-CLI / cross-platform | 5/10 |
| Public-project maturity | 5/10 |

## Findings (verified against the tree by the maintainer session before fixing)

- **P0 — private data lives in the git tree.** 17 `state/*.md` files (finances, journal, network, tasks, …) tracked, while `/ship` runs `git add .`. No automatic leak (push is a separate action), but personal data can be committed and later pushed to a fork/remote. **CONFIRMED** (`git ls-files state/` = 18 incl. .gitkeep; ship/SKILL.md:84).
- **P1 — updater's backup promise is broken.** update.sh claims customized skills/agents/hooks go to backup; it backs up skills+hooks but **not agents**, then overwrites agents. No dry-run, no transactional rollback, no post-update test, updater outside CI. **CONFIRMED**.
- **P1 — bus & guard have reproducible bypasses.** `context-bus-append.sh` does not validate `to`; a TAB in content produces invalid JSONL. `protect-state.sh` allowed any command that merely *contained* the helper's name (chain a direct bus write after it); archive could be effectively destroyed via allowed `mv`/redirects. **CONFIRMED**.
- **P1 — privacy/onboarding drift.** PRIVACY.md still declared v0.12.1; PRIVACY says scanning requires consent while `/setup` says "scan first" and the script listed app names pre-consent (local, names-only — but consent description didn't match behavior); README implied all guardrails are code-enforced while crisis-data and send/spend gates are partly prompt policy, especially off-Claude. **CONFIRMED**.
- **P1/P2 — green CI doesn't cover the main risks**: updater, private-data staging, template↔SCHEMAS consistency, helper-chain guard bypass, arbitrary JSON/UTF-8 on the bus, real skill behavior, Windows. `time-aware.sh` used macOS `date -j` with no GNU fallback (silent degradation on Linux). **CONFIRMED**.

One council finding was **rejected after verification**: "missing `.agents/skills` symlinks" — a fresh clone contains all 24 symlinks; the reviewing tool couldn't see symlinks.

## Response (fix/p0-data-boundary branch)

| Finding | Action |
|---------|--------|
| P0 data boundary | Personal templates moved to `templates/state/`; `state/*.md` gitignored (only SCHEMAS.md + context-bus.md stub remain tracked); session-start bootstraps missing state files from templates; `/ship` staging switched from `git add .` to an explicit allowlist + staged-diff check |
| Updater | agents backed up before overwrite; `--dry-run` flag; destructive confirmations default to No |
| Bus writer | validates `to`; escapes TAB/CR, strips other control chars; JSONL validity covered by tests (python3 json parse per line) |
| Guard | helper-name early-exit removed (chained writes now caught); redirects/`mv` from archive blocked |
| Privacy drift | PRIVACY.md versionless ("this repo"); `/setup` asks consent BEFORE the names scan (script defaults to non-personal detection; names behind `--with-names`); README marks each guardrail as hook-enforced vs contract |
| Cross-platform | `time-aware.sh` GNU `date -d` fallback |
| CI gaps | new tests: staging boundary, helper-chain bypass, bus JSON validity/TO validation, template bootstrap; updater deep-tests and Windows remain **open** (documented, not claimed) |

Deferred (tracked, not silently dropped): transactional updater rollback + post-update self-test, Windows CI, branch protection + SECURITY.md + Dependabot/CodeQL, GitHub Release flow.
