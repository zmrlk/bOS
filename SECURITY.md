# Security

## Reporting a vulnerability

Use GitHub's **private vulnerability reporting** on this repository (Security → Report a vulnerability). Please do not open public issues for security problems. You can expect an acknowledgement within a week; this is a one-maintainer project, so complex fixes may take longer — the report itself stays private until a fix ships.

## Threat model (read this before reporting)

bOS is a local-first folder opened in an AI coding CLI. Honest boundaries:

**In scope — worth reporting:**
- Personal data from `state/`, `profile.md`, or `.secrets/` reaching the git index, a commit, or any network call shipped in this repo
- A shipped script writing outside the bOS folder (except documented paths: `~/.claude/logs/`, LaunchAgents when you run the ntfy installer yourself)
- Secrets handling bugs (e.g. a hook echoing `.secrets/` contents into context)
- The guard hook or bus writer producing corrupted state that other components then trust

**Known and documented — not vulnerabilities:**
- The `protect-state` guard is a **best-effort speed bump against the model's mistakes, not a security boundary** ([HONESTY.md](HONESTY.md)). Bypasses via novel interpreter tricks are expected; we still patch the ones we learn about, so reports are welcome, just triaged as hardening.
- Hooks run **outside** the CLI permission model — the deny-list governs chat commands, not hook scripts.
- Your conversation content goes to the model provider's API (Anthropic/OpenAI/xAI, depending on the CLI you use). That is inherent to the product; see [PRIVACY.md](PRIVACY.md).
- Anything requiring an attacker who already has local access to your machine or your CLI session — at that point they have your data with or without bOS.

## Supported versions

Only the latest tagged release. There are no backports.
