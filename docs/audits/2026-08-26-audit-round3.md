# External audit round 3 — v0.13.2 (commit f86f500), 2026-08-26

Verdict: fresh clone 8/10 GO · upgrade path 7/10 CONDITIONAL GO · Windows 5/10 unsupported. The auditor independently confirmed the real v0.13.0 → v0.13.2 migration works (15 personal files untracked, kept on disk) and that the botched v0.13.1 upgrade is repaired by it. Five findings remained; all are fixed in v0.13.3.

## Findings and responses

| # | Finding | Response in v0.13.3 |
|---|---------|---------------------|
| P1 | **Rollback did not restore the git index.** After a forced self-test failure the updater restored files and VERSION but left 15 staged deletions — so "your installation is as it was" was false | The migration now records what it untracks; `rollback()` re-stages those paths, restoring an identical index. Root cause of the silent half-restore: `git add --quiet` is not a valid flag, and under `set -e` it aborted the rollback mid-loop. Fixed and proven: index checksum before == after |
| P1 | **The CI updater test could not fail.** Its fixture came from v0.13.1+, which ships no state files, so "untrack legacy state" migrated nothing — a green no-op | The job now materializes state files from templates and force-adds them to build a genuine legacy install, and **hard-fails if the fixture has nothing to migrate** (`FIXTURE IS A NO-OP`). Second regression job: forced self-test failure must leave the git index byte-identical |
| P1 | `test-updater` was not a required status check | Branch protection now requires `test (ubuntu-latest)`, `test (macos-latest)` and `test-updater` |
| P2 | The version in `profile.md` was never bumped — the updater looked for `bos_version:` while the template uses a markdown table row | The updater handles both the table row and the legacy key; verified in the Linux e2e (`profile.md → version 0.13.3`) |
| P2 | Consent gap: the default scan read the global git identity and counted Claude memory folders before consent; PRIVACY.md described a Desktop/Documents/Downloads scan that was never implemented; Dependabot vulnerability alerts were off | Git identity and memory-folder counts moved behind `--with-names` (post-consent), PRIVACY.md now describes what the scan actually does, vulnerability alerts enabled |

## Two of my own tests lied during this round (recorded, not hidden)

1. The tag filter `grep -v "^$(cat VERSION)$"` never matched, because tags carry a `v` prefix and `VERSION` does not — so the "previous release" resolved to the current one and the updater exited with "already up to date". The test looked green while doing nothing.
2. The forced-failure injection was **appended** to `tests/run.sh`, which ends in `exit 0` — the injected failure never executed, so the rollback path was never exercised.

Both are the same class as the round-2 lesson: a test must be shown to fail when the thing it guards is broken. The CI job now proves its own failure injection took effect before relying on it.

## Still open

- Windows: 67/68, experimental (`continue-on-error`), documented as unsupported in HONESTY.md.
- The guard remains a best-effort speed bump.
- Branch protection exempts admins by design, so a direct push can still bypass required checks.
