# Durable memory

bOS has one vendor-neutral durable-memory store: `memory/`. Claude, Codex and
Grok use the same plain files. It is local and entirely gitignored.

## Layout

| Path | Role |
|------|------|
| `memory/current/` | one active record per `scope/key` |
| `memory/conflicts/` | incompatible proposals; never auto-promoted |
| `memory/archive/` | superseded records and resolved conflict proposals |
| `memory/HOT.md` | generated startup cache: max 12 records / 2400 characters |
| `memory/ledger.jsonl` | append-only metadata and hashes; no memory plaintext |

Session digests remain search history, not canonical memory. Claude Code's own
`~/.claude/.../memory/` may still exist, but it is optional and host-specific.

## Trust model

The protocol permits only explicit user confirmation or a verified local/live
source. The helper validates the declared source/confidence pair, but cannot
independently prove that a model labelled it truthfully — that remains a
cross-CLI contract. Raw `web:`, `mail:`, `external:` and `model:` labels are
rejected. Only `user:` records can enter `HOT.md`; verified non-user facts stay
searchable and cold. Known secret, crisis and prompt-injection patterns are
rejected; regex filtering is defense-in-depth, not complete classification.

Review dates do not delete records. When the date passes, the record becomes
effectively stale and drops out of `HOT.md`; `audit` reports it for review.
Conflicting values go to quarantine and leave the current value unchanged.
Repeated identical proposals are idempotent. Explicit `supersede` moves every
proposal for that key to history as `resolved-accepted` or `resolved-rejected`,
so resolved conflicts do not keep resurfacing in recall/audit.

## Commands

```bash
bash scripts/bos-memory.sh init
bash scripts/bos-memory.sh remember user answer-style preference confirmed user:2026-08-26 - hot "Start with the answer."
bash scripts/bos-memory.sh recall answer-style
bash scripts/bos-memory.sh audit
bash scripts/bos-memory.sh supersede user answer-style preference confirmed user:2026-08-26 - hot "Start with the answer and cite evidence."
```

Direct model writes under `memory/` are blocked by Claude's guard. That is a
speed bump, not a security boundary; Codex and Grok follow the shared contract.
All helper writes use an atomic writer lock plus temporary files and atomic
rename for individual records and the hot cache. A dead-process lock is
recoverable; a live writer times out rather than corrupting another write. The
updater never replaces `memory/`.
