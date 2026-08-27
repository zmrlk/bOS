# Audit round 4 — durable cross-CLI memory

Date: 2026-08-26

Candidate: `0.14.0`, branch `codex/memory-v1`

Base: `v0.13.3` (`a5b3bcf`)
Remote status: **not pushed / not released**

## Baseline verdict

v0.13.3 memory was **PARTIAL**. Live `state/*.md`, the context bus, handoff and
lossy session digests survived sessions, while Claude Code also had a separate
host-managed memory. There was no canonical vendor-neutral fact store, no
conflict quarantine, no provenance ledger, and no equal read path for all CLIs.

## Council

Every peer received the same read-only review prompt.

| Peer | Result |
|------|--------|
| Claude | **GO**; residual keyword-filter weakness and Claude-only direct-write guard disclosed |
| GLM/ZAI | timed out before a verdict (initial run returned only a test preamble) |
| Grok | timed out |
| Agy/Gemini | empty response |
| independent Codex follow-up | timed out |

This is not reported as a four-model consensus. The release gate below rests on
reproduced code/test evidence; unavailable peers remain unavailable.

After the final conflict-resolution, ZIP-test and honesty fixes, Claude ran a
second static regression review: **GO, no new reproducible P0/P1**. It did not
re-run the suite; the host-run evidence below supplies that gate.

## What changed

- Canonical gitignored `memory/` store shared by Claude, Codex and Grok.
- Helper-only writes with stable keys, declared provenance, content hashes,
  atomic record replacement and a serialized writer lock.
- Conflicting values are quarantined; superseded values are archived.
- Repeated identical conflicts are idempotent; explicit supersede resolves all
  proposals for the key into accepted/rejected history.
- Review dates remove stale values from the bounded startup cache without
  deleting history.
- Only direct `user:` records can be hot. Verified file/live/import facts are
  searchable but cold.
- Raw external/model source labels plus known secret, crisis and prompt-
  injection patterns are rejected.
- `/remember` and `/recall` use the same store. Session summaries remain search
  history and never auto-promote into canonical truth.

## Findings found during this round

### P1 — post-update self-test falsely required a Git checkout (fixed)

Reproduction: a real v0.13.3 ZIP-style installation updated to the candidate,
preserved profile and memory checksums, but its post-update test failed at the
new `git check-ignore memory/...` assertion because no `.git/` existed.

Fix: git-bound assertions now skip only when Git/a checkout is unavailable and
remain exercised by CI. Re-run: updater self-test `85 passed`, profile unchanged,
memory SHA-256 unchanged.

### P1 — safety regexes are incomplete classifiers (disclosed, not “fixed”)

Known-pattern filters catch obvious values and are tested, but cannot cover all
languages/paraphrases or prove a caller's source label. Documentation now calls
provenance an auditable assertion, not attestation, and the filters defense in
depth rather than a complete security boundary.

### P2 — cross-CLI write enforcement is asymmetric (open, explicit)

Claude's PreToolUse guard blocks direct `memory/` writes. Codex and Grok have no
equivalent shipped guard and follow `AGENTS.md`/their rule file best-effort. The
data format and helper are shared; enforcement equality is not claimed.

### P2 — Windows remains experimental (open)

Memory uses Bash/coreutils available in typical Git Bash, but the existing
Windows CI job is non-required and the full repository still has known symlink
issues. Windows memory behavior is **NIEZWERYFIKOWANE** until CI runs on this
candidate.

### P2 — interactive model-led `/setup` remains unverified (open)

A clean filesystem onboarding fixture passed: 15 state templates materialized,
empty memory initialized, default scan did not reveal the fake Git identity, and
the next session recalled a saved hot preference. A real interactive CLI
conversation through every `/setup` question is **NIEZWERYFIKOWANE**.

## Evidence

- macOS: `bash tests/run.sh` → **93 passed, 0 failed**.
- Debian `stable-slim`, read-only bind: **83 passed, 0 failed**; 10 Git/Python-
  dependent assertions skipped because the minimal image intentionally lacks
  Git/Python. All durable-memory behavior tests ran and passed.
- Six concurrent writers: six current records, no lost record, lock removed.
- v0.13.3 → v0.14.0 update: profile exact, memory SHA-256 exact, self-test green.
- Forced failed update: version rolled back to 0.13.3, Git index checksum exact,
  memory SHA-256 exact.
- Clean start: state templates materialized, empty hot cache labelled as data;
  second start recalled the explicit preference.

## Verdict

**GO for local commit and GitHub CI.** Release remains gated on required macOS,
Linux and updater jobs at the exact commit. Windows is informative, not a gate.
`git push` and release creation require separate user approval.
