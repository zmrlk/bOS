# External audit round 2 — v0.13.1 (commit ec68513), 2026-08-26

Second independent pass, run against the published HEAD. It confirmed the P0 data boundary works **on a fresh clone** — and found that the **updater did not deliver it to existing installs**. Fixed in v0.13.2.

## The blocker it found (maintainer error, worth naming)

The v0.13.1 release notes claimed the updater was "proven end-to-end both ways". That claim rested on a flawed fixture: the "old install" in my sandbox was a **copy of the new tree**, so it already contained the new `.gitignore`. A real v0.13.0 → v0.13.1 update failed: 55 PASS / 5 FAIL in the post-update self-test, because `update.sh` never copied `.gitignore` and never untracked the legacy `state/*.md` files. The updater then correctly offered a rollback — but the update did not deliver the release's headline fix.

Lesson recorded: **a test whose fixture is derived from the artifact under test proves nothing.** The old side of a migration test must come from the actual previous release.

## Findings and responses

| # | Finding | Response in v0.13.2 |
|---|---------|---------------------|
| P0 | `update.sh` did not ship `.gitignore` (nor HONESTY/SECURITY/docs) and did not untrack legacy `state/*.md` | Copy manifest now includes `.gitignore`, `.gitattributes`, `HONESTY.md`, `SECURITY.md`, `docs/`, `.github/`. New migration step untracks legacy personal state with `git rm --cached` (files stay on disk), asks first |
| P1 | Rollback left newly created directories (`templates/`) behind | Rollback now removes items that did not exist before the update |
| P1 | Banner said "profile.md — untouched" while bumping `bos_version` | Banner now says "your content untouched (only the bos_version field is bumped)" |
| P1 | No updater test in CI — only a local sandbox claim | CI job `test-updater` builds the old install from the **previous git tag**, inits it as a git repo, runs the update and asserts: version advanced, profile content intact, `.gitignore` migrated, zero personal files left tracked, `state/finances.md` still on disk, agents backed up |
| P1 | Guard let `cp /dev/null state/archive/x` and `cp`/`mv` onto the bus through | `cp` added to the archive pattern; `cp`/`mv`/`dd`/`shred`/`rm` added to the bus pattern. All six payloads are now test cases |
| P1 | SECURITY.md pointed at GitHub Private Vulnerability Reporting while the setting was disabled | Enabled on the repository |
| P2 | `.gitignore` framed as "physically impossible" to commit data | HONESTY.md now states plainly: it is protection against mistakes, `git add -f` still works deliberately |
| P2 | README lead sentence bundled a prompt-level guarantee (crisis data) with "enforced by hooks" | Lead rewritten: "where a guardrail can be enforced by code it is a hook" + pointer to HONESTY.md |
| P2 | Windows CI is red (59/60, roster check) and only green via `continue-on-error` | HONESTY.md per-CLI table now says Windows is unverified/unsupported until that job is green |
| — | README showed v0.13.0, profile-template 0.12.1, schemas ≠ templates, "Rule 12" pointing at nothing | Already fixed in the working tree between `ec68513` and this release: versions aligned, 11 templates rewritten to match SCHEMAS, `Rule 12` → "AGENTS.md rule 9", audit doc annotated as fixed |

## Still open (documented, not claimed)

- Windows support (CI job stays experimental, `continue-on-error`).
- The guard remains a best-effort speed bump: novel interpreter routes can still write anywhere. See HONESTY.md.
- CodeQL: skipped on purpose — no shell support.
